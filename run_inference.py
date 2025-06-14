import pandas as pd
import torch
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import PayloadSchemaType
import google.generativeai as genai
import time
import os
import argparse
import logging
from typing import List, Dict, Any, Optional
import numpy as np
from datetime import datetime
import re
import random

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f"lenden_qa_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# === CONFIGURATION ===
GEMINI_API_KEY = "AIzaSyBcieQSbcnDkWnxcRyHKusdp5-TQWK-5Fs"
QRDANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.ujjoittTtBdMDI9jZezsz4FnADyoN9yQQZps-xqFy4A"
QRDANT_URL = "https://69e70495-9868-4a4e-bb21-9aad53f3d255.us-west-1-0.aws.cloud.qdrant.io:6333"
COLLECTION_NAME = "Lenden_ faqs"
TOP_K = 5  # Increased from 3 to 5 for better context coverage
MIN_CONFIDENCE = 0.5  # Decreased from 0.6 to capture more potential matches
MAX_RETRIES = 3
TEMPERATURE = 0.2

# Define conversation styles to make responses more human-like
CONVERSATION_STYLES = [
    {
        "tone": "friendly",
        "phrases": [
            "Happy to help with this!",
            "I'd be glad to explain.",
            "Great question!",
            "Let me share some insights on this.",
        ]
    },
    {
        "tone": "professional",
        "phrases": [
            "Based on the information available,",
            "According to our policies,",
            "Here's what you need to know:",
            "Let me clarify this for you.",
        ]
    },
    {
        "tone": "empathetic",
        "phrases": [
            "I understand this can be confusing.",
            "I see what you're asking about.",
            "Let me address your concerns.",
            "This is an important question.",
        ]
    }
]


class LendenQASystem:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.setup_models()
        
    def setup_models(self):
        """Initialize models and clients"""
        logger.info("Setting up models and connections...")
        
        # Setup device
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        logger.info(f"Using device: {self.device}")
        
        # Load embedding model with error handling
        try:
            self.embedding_model = SentenceTransformer("all-MiniLM-L6-v2").to(self.device)
            logger.info("Embedding model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load embedding model: {e}")
            raise RuntimeError("Critical failure: Embedding model could not be initialized")
            
        # Connect to Qdrant
        retry_count = 0
        while retry_count < MAX_RETRIES:
            try:
                self.qdrant = QdrantClient(
                    url=self.config["QRDANT_URL"], 
                    api_key=self.config["QRDANT_API_KEY"]
                )
                # Verify connection by checking collection info
                collection_info = self.qdrant.get_collection(self.config["COLLECTION_NAME"])
                logger.info(f"Connected to Qdrant collection: {self.config['COLLECTION_NAME']}")
                logger.info(f"Collection size: {collection_info.points_count} points")
                break
            except Exception as e:
                retry_count += 1
                logger.warning(f"Qdrant connection attempt {retry_count} failed: {e}")
                if retry_count >= MAX_RETRIES:
                    logger.error("Failed to connect to Qdrant after multiple attempts")
                    raise
                time.sleep(2)
                
        # Configure Gemini
        try:
            genai.configure(api_key=self.config["GEMINI_API_KEY"])
            generation_config = {
                "temperature": TEMPERATURE,
                "top_p": 0.95,
                "top_k": 40,
                "max_output_tokens": 1024,
            }
            
            safety_settings = [
                {
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                },
                {
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                },
                {
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                },
                {
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                }
            ]
            
            self.gemini = genai.GenerativeModel(
                model_name="gemini-1.5-flash",
                generation_config=generation_config,
                safety_settings=safety_settings
            )
            logger.info("Gemini model initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Gemini: {e}")
            raise

    def identify_question_column(self, df: pd.DataFrame) -> str:
        """Intelligently identify the column that contains questions"""
        
        # Check if dataframe is empty
        if df.empty:
            logger.error("Empty dataframe provided")
            raise ValueError("Input CSV file is empty")
            
        # Strategy 1: Look for columns with common question identifiers
        question_identifiers = ['question', 'query', 'prompt', 'user_query', 'input', 'text']
        for col in df.columns:
            if col.lower() in question_identifiers or any(q in col.lower() for q in question_identifiers):
                logger.info(f"Found question column by name: {col}")
                return col
                
        # Strategy 2: Analyze content - questions often end with ? or have question words
        question_markers = ['what', 'how', 'when', 'where', 'why', 'who', 'can', 'should', 'will', 'is', 'are', '?']
        
        # Analyze sample of text from each column to identify question-like content
        column_scores = {}
        
        for col in df.columns:
            # Skip if column doesn't contain string data
            if not pd.api.types.is_string_dtype(df[col]):
                continue
                
            # Sample data (up to 10 rows)
            samples = df[col].dropna().astype(str).head(10).tolist()
            if not samples:
                continue
                
            # Score based on question indicators
            score = 0
            for sample in samples:
                if len(sample) < 10:  # Too short to be a question
                    continue
                    
                sample_lower = sample.lower()
                # Check for question marks
                if '?' in sample:
                    score += 3
                
                # Check for question words
                for marker in question_markers:
                    if sample_lower.startswith(marker + ' '):
                        score += 2
                    elif f" {marker} " in sample_lower:
                        score += 1
                        
                # Check for reasonable length (questions are usually more than a few words)
                words = sample.split()
                if 4 <= len(words) <= 30:
                    score += 1
                    
            # Record average score for this column
            column_scores[col] = score / len(samples) if samples else 0
        
        # Select column with highest question score
        if column_scores:
            best_column = max(column_scores.items(), key=lambda x: x[1])
            if best_column[1] > 1.5:  # Threshold for reasonable confidence
                logger.info(f"Identified question column by content analysis: {best_column[0]}")
                return best_column[0]
        
        # Strategy 3: If we can't determine, use the first string column that's not 'id' or similar
        for col in df.columns:
            if pd.api.types.is_string_dtype(df[col]) and not re.match(r'(id|index|key)$', col.lower()):
                logger.warning(f"Could not confidently identify question column, using first string column: {col}")
                return col
                
        # If all else fails
        logger.error("Could not identify a question column in the CSV")
        raise ValueError("Could not detect a column containing questions in the input CSV")
        
    def weighted_score(self, hit):
        """Calculate weighted score for ranking results"""
        confidence = hit.payload.get("confidence", 0)
        qdrant_score = hit.score or 0
        
        # Dynamic weighting based on confidence level
        if confidence >= 0.8:
            confidence_weight = 0.8  # Heavily favor high-confidence answers
        else:
            confidence_weight = 0.6
            
        return confidence_weight * confidence + (1 - confidence_weight) * qdrant_score

    def process_query(self, user_query: str) -> str:
        """Process a single query and return the response"""
        # 1. Extract sub-queries to handle complex questions
        split_prompt = f"""
Break down this user query into clear, individual questions or aspects that need to be addressed.
Only extract the actual questions/requests, not any background information.

User query: "{user_query}"

Return ONLY the key questions/requests, each on a new line with a dash. 
If the query is already simple and focused, just return it as a single item.
"""
        try:
            split_response = self.gemini.generate_content(split_prompt)
            split_text = split_response.text.strip()
            sub_queries = [line.strip("-• ").strip() for line in split_text.split("\n") if line.strip() and not line.isspace()]
            
            # If we got no sub-queries or split failed, use original query
            if not sub_queries:
                sub_queries = [user_query]
                
            logger.info(f"Extracted {len(sub_queries)} sub-queries from user question")
        except Exception as e:
            logger.warning(f"Sub-query extraction failed: {e}")
            sub_queries = [user_query]  # Fall back to original query

        # 2. Get relevant context from vector DB for each sub-query
        all_retrieved_chunks = []
        
        # Track scores to prevent duplicate chunks but with different scores
        seen_chunks = {}
        
        for sub_query in sub_queries:
            logger.info(f"Processing sub-query: {sub_query}")
            
            try:
                # Encode query to vector
                query_vector = self.embedding_model.encode(sub_query, device=self.device).tolist()
                
                # Search vector database
                search_results = self.qdrant.search(
                    collection_name=self.config["COLLECTION_NAME"],
                    query_vector=query_vector,
                    limit=15  # Get more results initially, then filter and rank
                )
                
                # Filter by minimum confidence and remove duplicates
                filtered_results = []
                for hit in search_results:
                    chunk_text = hit.payload.get("text", "")
                    
                    # Skip if confidence is too low
                    if hit.payload.get("confidence", 0) < self.config["MIN_CONFIDENCE"]:
                        continue
                        
                    # Check for duplicates or near-duplicates
                    if chunk_text in seen_chunks:
                        # Keep the one with higher score
                        if self.weighted_score(hit) > seen_chunks[chunk_text]:
                            seen_chunks[chunk_text] = self.weighted_score(hit)
                        else:
                            continue
                    else:
                        seen_chunks[chunk_text] = self.weighted_score(hit)
                        filtered_results.append(hit)
                
                # Rank and add top results
                ranked_results = sorted(filtered_results, key=self.weighted_score, reverse=True)
                top_hits = ranked_results[:self.config["TOP_K"]]
                
                for hit in top_hits:
                    question = hit.payload.get("text", "Unknown question")
                    answer = hit.payload.get("answer", "No answer available")
                    confidence = hit.payload.get("confidence", 0)
                    score = hit.score or 0
                    
                    # Create formatted context chunk
                    context = {
                        "question": question,
                        "answer": answer,
                        "confidence": confidence,
                        "score": score,
                        "weighted_score": self.weighted_score(hit)
                    }
                    all_retrieved_chunks.append(context)
                    
            except Exception as e:
                logger.error(f"Error during vector search for sub-query '{sub_query}': {e}")
        
        # Sort all chunks by weighted score and take top N
        all_retrieved_chunks = sorted(all_retrieved_chunks, key=lambda x: x["weighted_score"], reverse=True)
        top_chunks = all_retrieved_chunks[:10]  # Take top 10 across all sub-queries
        
        # Format chunks for the prompt
        formatted_chunks = []
        for i, chunk in enumerate(top_chunks):
            formatted_chunks.append(
                f"[Context #{i+1}]\n"
                f"Q: {chunk['question']}\n"
                f"A: {chunk['answer']}\n"
                f"Relevance: {chunk['weighted_score']:.2f}\n"
            )
        
        context_text = "\n".join(formatted_chunks)
        
        # 3. Generate human-like response with Gemini
        # Choose a random conversation style to add variety
        style = random.choice(CONVERSATION_STYLES)
        opener = random.choice(style["phrases"])

        final_prompt = f"""
You are a knowledgeable, friendly customer service representative for Lenden.

The customer has asked: "{user_query}"

Use ONLY the following trusted information to answer:
{context_text}

Your task:
1. Analyze how well the retrieved information addresses the user's question
2. Create a helpful, conversational response that directly answers the user's question
3. If the retrieved information doesn't fully address the question, acknowledge this honestly
4. NEVER make up information not present in the context
5. Organize information in a clear, easy-to-understand way
6. Use a {style["tone"]} tone throughout your response
7. Start your response with a brief greeting

Guidelines:
- Be concise but thorough
- Use bullet points or numbered lists when helpful
- Avoid phrases like "according to the context" or "based on the retrieved information"
- If highly technical questions come up that aren't covered, suggest contacting customer support
- Write as a human would, not as an AI

YOUR RESPONSE:
"""
        try:
            for attempt in range(MAX_RETRIES):
                try:
                    response = self.gemini.generate_content(final_prompt)
                    answer = response.text.strip()
                    
                    # Apply some post-processing to ensure quality
                    # Remove any disclaimers about being an AI
                    answer = re.sub(r"(As an AI|I'm an AI|As a language model|As an assistant)", "", answer)
                    
                    # Clean up any references to the context numbering
                    answer = re.sub(r"\[Context #\d+\]", "", answer)
                    
                    # Ensure the response isn't too long
                    if len(answer) > 2000:
                        answer = answer[:1950] + "..."
                        
                    return answer
                    
                except Exception as e:
                    if attempt == MAX_RETRIES - 1:
                        raise
                    logger.warning(f"Gemini generation failed (attempt {attempt+1}): {e}")
                    time.sleep(1)
                    
        except Exception as e:
            logger.error(f"All attempts to generate response failed: {e}")
            return "I apologize, but I'm unable to provide a response at the moment. Please contact customer support for assistance with your query."

    def process_csv(self, input_path: str, output_path: str):
        """Process all questions in CSV file and save responses"""
        start_time = time.time()
        logger.info(f"Starting to process CSV: {input_path}")
        
        try:
            # Read CSV file
            df = pd.read_csv(input_path)

            logger.info(f"Loaded CSV with {len(df)} rows and columns: {', '.join(df.columns)}")
            
            # Determine which column contains the questions
            question_column = self.identify_question_column(df)
            logger.info(f"Using '{question_column}' as the question column")
            
            # Create empty response column if it doesn't exist
            if 'response' not in df.columns:
                df['response'] = None
                
            # Process each question
            for idx, row in df.iterrows():
                user_query = str(row[question_column])
                
                # Skip empty queries
                if pd.isna(user_query) or not user_query.strip():
                    logger.warning(f"Skipping empty question at row {idx+1}")
                    df.at[idx, 'response'] = "No question provided"
                    continue
                
                # Process query and capture response
                try:
                    logger.info(f"Processing question {idx+1}/{len(df)}: {user_query[:50]}...")
                    response = self.process_query(user_query)
                    df.at[idx, 'response'] = response
                    
                    # Logging
                    logger.info(f"✓ Generated response for row {idx+1} ({len(response)} chars)")
                    
                    # Add small random delay to avoid rate limiting and appear more human-like
                    time.sleep(random.uniform(0.8, 2.0))
                    
                except Exception as e:
                    logger.error(f"Failed to process row {idx+1}: {e}")
                    df.at[idx, 'response'] = "Error: Unable to generate response due to technical issues."
                
                # Save progress every 10 rows
                if (idx + 1) % 10 == 0 or idx == len(df) - 1:
                    df.to_csv(output_path, index=False)
                    logger.info(f"Progress saved to {output_path} ({idx+1}/{len(df)} complete)")
            
            # Final save
            df.to_csv(output_path, index=False)
            
            # Summary statistics
            total_time = time.time() - start_time
            avg_time_per_query = total_time / len(df) if len(df) > 0 else 0
            
            logger.info(f"✅ Processing complete! Total time: {total_time:.2f} seconds")
            logger.info(f"Average time per query: {avg_time_per_query:.2f} seconds")
            logger.info(f"Responses saved to: {output_path}")
            
        except Exception as e:
            logger.error(f"Error processing CSV file: {e}")
            raise


def main():
    """Main function for CLI interaction"""
    parser = argparse.ArgumentParser(description='Lenden FAQ Response System')
    parser.add_argument('--input', '-i', type=str, help='Input CSV file path', default="test_questions.csv")
    parser.add_argument('--output', '-o', type=str, help='Output CSV file path', default="inference_output.csv")
    args = parser.parse_args()
    
    print("\n" + "="*60)
    print("  LENDEN FAQ RESPONSE SYSTEM")
    print("  Current Date: 2025-06-14 10:10:06 UTC")
    print("="*60)
    
    config = {
        "GEMINI_API_KEY": GEMINI_API_KEY,
        "QRDANT_API_KEY": QRDANT_API_KEY,
        "QRDANT_URL": QRDANT_URL,
        "COLLECTION_NAME": COLLECTION_NAME,
        "TOP_K": TOP_K,
        "MIN_CONFIDENCE": MIN_CONFIDENCE,
    }
    
    try:
        # Validate input file exists
        if not os.path.exists(args.input):
            print(f"❌ Error: Input file '{args.input}' does not exist")
            return 1
            
        print(f"\n🔍 Initializing system...")
        system = LendenQASystem(config)
        
        print(f"📄 Processing input file: {args.input}")
        print(f"💾 Output will be saved to: {args.output}")
        
        # Process the CSV file
        system.process_csv(args.input, args.output)
        
        print("\n✅ Processing complete!")
        print(f"📊 Results saved to {args.output}")
        print("="*60 + "\n")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        logger.exception("Unhandled exception in main:")
        return 1
        
    return 0


if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)
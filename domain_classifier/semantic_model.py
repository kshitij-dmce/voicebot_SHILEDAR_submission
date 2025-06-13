from sentence_transformers import SentenceTransformer, util
import json
import torch

class SemanticDomainClassifier:
    def __init__(self, sample_file="domain_samples_cleaned.json"):
        self.model = SentenceTransformer("sentence-transformers/distiluse-base-multilingual-cased-v2")

        with open(sample_file, "r", encoding="utf-8") as f:
            self.domains = json.load(f)

        self.domain_vectors = self._encode_samples()

    def _encode_samples(self):
        vectors = {}
        for label, examples in self.domains.items():
            vectors[label] = self.model.encode(examples, convert_to_tensor=True)
        return vectors

    def predict(self, query):
        query_vec = self.model.encode(query, convert_to_tensor=True)
        best_score = -1
        best_label = None
        for label, vectors in self.domain_vectors.items():
            score = util.cos_sim(query_vec, vectors).mean().item()
            if score > best_score:
                best_score = score
                best_label = label
        return best_label

    def predict_top_k(self, query, k=3):
        query_vec = self.model.encode(query, convert_to_tensor=True)
        scores = []

        for label, vectors in self.domain_vectors.items():
            score = util.cos_sim(query_vec, vectors).mean().item()
            scores.append((label, score))

        # Sort by similarity score in descending order
        scores.sort(key=lambda x: x[1], reverse=True)
        return scores[:k]

from modules.inference_pipeline import answer_query

if __name__ == "__main__":
    user_input = input("🧠 Enter your (possibly complex) question: ")
    print("\n🤖 Gemini Response:\n")
    response = answer_query(user_input)
    print(response)

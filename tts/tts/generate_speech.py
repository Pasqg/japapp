from openai import OpenAI


if __name__ == "__main__":
    phrases = [
        "秋の葉は黄色いです",
    ]

    with open("openai.key", 'r') as file:
        client = OpenAI(api_key=file.read())
        for phrase in phrases:
            speech_file_path = f"generated/{phrase}.mp3"
            response = client.audio.speech.create(
                model="tts-1",
                voice="shimmer",
                input=phrase,
                speed=1.0,
            )
            response.stream_to_file(speech_file_path)

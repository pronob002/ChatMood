from flask import Flask, request, jsonify
from flask_cors import CORS, cross_origin
from transformers import DistilBertTokenizer, DistilBertForSequenceClassification
from collections import defaultdict
import re

app = Flask(__name__)
CORS(app)

def analyze_sentiment(chat_content):
    try:
        message_timestamps_authors = []
        current_author = None
        current_message = ""

        for line in chat_content.split('\n'):
            match = re.match(r'(\d{2}/\d{2}/\d{4}, \d{1,2}:\d{2}\s*[ap]m) - (.+): (.*)', line)
            if match:
                if current_author:
                    message_timestamps_authors.append((current_author, current_message))
                current_author, current_message = match.group(2), match.group(3)
            else:
                current_message += " " + line.strip()

        if not message_timestamps_authors:
            return {'error': 'No valid messages found in the chat.'}
        else:
            authors, messages = zip(*message_timestamps_authors)

            # Additional code to count total messages and messages by each author
            total_messages = len(messages)
            messages_by_author = defaultdict(int)
            for author in authors:
                messages_by_author[author] += 1

            tokenizer = DistilBertTokenizer.from_pretrained("distilbert-base-uncased")
            model = DistilBertForSequenceClassification.from_pretrained("distilbert-base-uncased-finetuned-sst-2-english")

            sentiments_by_author = defaultdict(list)

            for author, message in zip(authors, messages):
                inputs = tokenizer(message, return_tensors="pt", truncation=True, max_length=512)
                outputs = model(**inputs)
                logits = outputs.logits
                probabilities = logits.softmax(dim=1)
                sentiment_score = probabilities[:, 1].item()

                sentiments_by_author[author].append(sentiment_score)

            total_authors = len(set(authors))

            percentage_by_author = {}
            for author, scores in sentiments_by_author.items():
                positive_percentage = sum(score > 0.7 for score in scores) / len(scores) * 100
                negative_percentage = sum(score < 0.3 for score in scores) / len(scores) * 100
                neutral_percentage = 100 - (positive_percentage + negative_percentage)
                percentage_by_author[author] = {
                    'positive': positive_percentage,
                    'negative': negative_percentage,
                    'neutral': neutral_percentage
                }

            return {
                'total_authors': total_authors,
                'total_messages': total_messages,
                'messages_by_author': dict(messages_by_author),
                'percentage_by_author': percentage_by_author
            }

    except Exception as e:
        return {'error': str(e)}

@app.route('/upload', methods=['POST'])
@cross_origin()
def upload_file():
    try:
        uploaded_file = request.files['file']
        content = uploaded_file.read().decode('utf-8')

        sentiment_analysis_result = analyze_sentiment(content)

        return jsonify({
            'message': 'File uploaded and analyzed successfully',
            'result': sentiment_analysis_result
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=8000)

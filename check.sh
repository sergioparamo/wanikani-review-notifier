#!/bin/bash

set -egit pu

RESPONSE_JSON=$(curl -s -H "Authorization: Bearer $WANIKANI_API_TOKEN" \
                      "https://api.wanikani.com/v2/assignments?immediately_available_for_review=true")

TOTAL_COUNT=$(echo "$RESPONSE_JSON" | jq '.total_count')

echo "WaniKani check complete. Reviews found: $TOTAL_COUNT"

if [ "$TOTAL_COUNT" -gt 0 ]; then
  
  SUBJECT_TYPES=$(echo "$RESPONSE_JSON" | jq -r '.data[].data.subject_type')
  
  RADICAL_COUNT=$(echo "$SUBJECT_TYPES" | grep -c "radical" || true)
  KANJI_COUNT=$(echo "$SUBJECT_TYPES" | grep -c "kanji" || true)
  VOCAB_COUNT=$(echo "$SUBJECT_TYPES" | grep -c "vocabulary" || true)

  echo "Breakdown: R: $RADICAL_COUNT, K: $KANJI_COUNT, V: $VOCAB_COUNT"
  
  SUBJECT="${TOTAL_COUNT} WaniKani reviews available"
  
 BODY_TEXT=$(cat <<EOF
Hey there!
You have ${TOTAL_COUNT} WaniKani reviews available. More specifically, you have:
* ${RADICAL_COUNT} radicals to review
* ${KANJI_COUNT} kanji to review
* ${VOCAB_COUNT} vocab words to review
https://www.wanikani.com/
頑張ってください!
EOF
)

BODY_HTML=$(cat <<EOF
<p>Hey there!</p>
<p>You have <strong>${TOTAL_COUNT} WaniKani reviews available</strong>. More specifically, you have:</p>
<ul>
    <li>${RADICAL_COUNT} radicals to review</li>
    <li>${KANJI_COUNT} kanji to review</li>
    <li>${VOCAB_COUNT} vocab words to review</li>
</ul>
<p><a href="https://www.wanikani.com/">https://www.wanikani.com/</a></p>
<p>頑張ってください!</p>
EOF
)
  
  PAYLOAD=$(jq -n \
              --arg from_email "$FROM_EMAIL" \
              --arg my_email "$MY_EMAIL" \
              --arg subject "$SUBJECT" \
              --arg text "$BODY_TEXT" \
              --arg html "$BODY_HTML" \
              '{
                "Messages": [
                  {
                    "From": {
                      "Email": $from_email,
                      "Name": "WaniKani Notifier"
                    },
                    "To": [
                      {
                        "Email": $my_email,
                        "Name": "WaniKani User"
                      }
                    ],
                    "Subject": $subject,
                    "TextPart": $text,
                    "HTMLPart": $html
                  }
                ]
              }')
  
  echo "Sending email via Mailjet..."
  curl -s -X POST "https://api.mailjet.com/v3.1/send" \
  -u "$MAILJET_API_KEY:$MAILJET_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
  
  echo "Notification sent."

else
  echo "No reviews found. No notification sent."
fi

echo "Script finished."
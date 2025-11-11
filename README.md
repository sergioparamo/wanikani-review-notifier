# WaniKani Review Notifier 🦀

A simple, fast, and dependency-free alternative to get email notifications for new WaniKani reviews.

This project is intentionally minimal. It uses **zero external dependencies** and no separate hosting service. It runs entirely within **GitHub Actions** using a simple **Bash script**.

This architecture is 100% free by combining the generous free tiers of GitHub Actions and Mailjet.

## 🚀 The Stack

* **Scheduler:** GitHub Actions (running every 8 minutes)
* **Runner:** GitHub Actions (Standard Ubuntu runner)
* **Logic:** A single `check.sh` Bash script
* **Tools:** `curl` and `jq` (pre-installed on the runner)
* **Notifier:** Mailjet (6,000 emails/month, 200/day free plan)

## 💡 How It Works

1.  **Schedule:** The `.github/workflows/wanikani-check.yml` file wakes up **every 8 minutes**. (This stays safely under Mailjet's 200 email/day limit).
2.  **Checkout:** The workflow checks out your repository's code.
3.  **Set Permissions:** It runs `chmod +x check.sh` to ensure the script has permission to execute.
4.  **Execute:** It runs the `check.sh` script, passing in your API keys and email settings as environment variables.
5.  **`check.sh` Logic:**
    * Calls the WaniKani API using `curl`.
    * Parses the JSON response using `jq` and `grep` to get the full breakdown of radicals, kanji, and vocabulary.
    * If `count > 0`, it uses `curl` again to send a formatted JSON payload to the Mailjet API.

## 🛠️ Setup Guide

### Step 1: Fork the Repository

Click the **"Fork"** button at the top of this page to copy this project to your own GitHub account. The workflow files are already included.

### Step 2: Get Mailjet API Keys

1.  Create a [Free Plan Account](https://www.mailjet.com/pricing/) (6,000 emails/month).
2.  Go to your Account settings -> **"API Keys"**.
3.  You will see one **API Key** (public) and one **Secret Key** (private).
4.  Save both. These are your `MAILJET_API_KEY` and `MAILJET_SECRET_KEY`.

### Step 3: Get WaniKani API Token

1.  Go to your WaniKani account settings.
2.  **API Tokens** -> [Generate a new Personal Access Token (V2)](https://www.wanikani.com/settings/personal_access_tokens).
3.  Give it `assignments:read` permissions.
4.  Save this token. This is your `WANIKANI_API_TOKEN`.

### Step 4: Add Secrets and Variables

Go to your **forked** repository -> **Settings** -> **Secrets and variables** -> **Actions**.

You need to create **three Secrets** (for sensitive data) and **two Variables** (for configuration).

#### Secrets
Create these in the **Secrets** tab.
| Name | Value |
| :--- | :--- |
| `WANIKANI_API_TOKEN` | The token you got from WaniKani. |
| `MAILJET_API_KEY` | Your (public) API Key from Mailjet. |
| `MAILJET_SECRET_KEY`| Your (private) Secret Key from Mailjet. |

#### Variables
Create these in the **Variables** tab.
| Name | Value |
| :--- | :--- |
| `MY_EMAIL` | The destination email (e.g., `your.name@gmail.com`). |
| `FROM_EMAIL` | The sender email. |


## 💡 Final Tip: How to Avoid the Spam Folder
Email providers can be aggressive with automated messages. Here are two options to ensure you always see your notifications.

Use Different Sender and Recipient Emails We highly recommend using different addresses for your FROM_EMAIL and MY_EMAIL variables. If your FROM_EMAIL and MY_EMAIL are the same (or on the same domain), email providers (like Gmail) often see this as a sign of spoofing or automated spam and may filter the messages.

Create an Inbox Filter To guarantee the emails land in your main inbox, create a filter that searches for the subject line keywords: "WaniKani reviews available".

# API Keys Required for Rapture Gauge

## Required API Keys (Priority Order)

### 1. OpenAI API Key ⭐ REQUIRED
- **Get it from:** https://platform.openai.com/api-keys
- **Cost:** ~$20-30/month for GPT-4 with our usage
- **Used for:** Analyzing news articles for prophecy relevance
- **Free tier:** $5 credit for new accounts

### 2. NewsAPI.org Key ⭐ REQUIRED
- **Get it from:** https://newsapi.org/register
- **Cost:** FREE (Developer plan - 100 requests/day)
- **Used for:** Fetching global news articles
- **Limits:** 100 requests/day, 500 requests/month

### 3. USGS Earthquake API 🆓 NO KEY NEEDED
- **URL:** https://earthquake.usgs.gov/fdsnws/event/1/
- **Cost:** FREE, no authentication required
- **Used for:** Real-time earthquake monitoring

### 4. Jerusalem Post RSS 🆓 NO KEY NEEDED
- **URL:** https://www.jpost.com/rss
- **Cost:** FREE, public RSS feeds

### 5. Times of Israel RSS 🆓 NO KEY NEEDED
- **URL:** https://www.timesofisrael.com/feed/
- **Cost:** FREE, public RSS feeds

## Optional API Keys (Enhanced Features)

### 6. Anthropic Claude API (Backup for OpenAI)
- **Get it from:** https://console.anthropic.com/
- **Cost:** Similar to OpenAI
- **Used for:** Fallback if OpenAI fails

### 7. Open Doors API
- **Get it from:** Contact Open Doors USA
- **Cost:** May require partnership
- **Used for:** Christian persecution data

### 8. Atlantic Council CBDC Tracker
- **URL:** Public data, no API key needed
- **Used for:** Digital currency tracking

## Setup Instructions

1. **Get your OpenAI key first** (most important)
2. **Register for NewsAPI.org** (free and quick)
3. Other sources work without keys

## Monthly Cost Estimate

With optimization:
- OpenAI GPT-4: ~$25/month
- NewsAPI: FREE (developer tier)
- Everything else: FREE
- **Total: ~$25-30/month**

## Where to Enter Keys in App

The app will have a Settings screen where you enter:
1. OpenAI API Key
2. NewsAPI Key
3. Optional: Claude API Key (backup)

Keys are stored securely in iOS Keychain.
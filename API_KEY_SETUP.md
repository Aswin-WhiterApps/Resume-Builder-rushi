# Hugging Face API Key Setup Guide

### Step 1: Add Your API Key

Open the file: **`lib/constants/hugging_face_config.dart`**

Find this line:
```dart
static const String? apiToken = null; // Replace null with your token: 'hf_your_token_here'
```

Replace `null` with your token in quotes:
```dart
static const String? apiToken = 'hf_your_actual_token_here';
```

### Step 3: Save and Run

That's it! The API key will be automatically loaded when the app starts.

## Important Notes

### Is an API Key Required?

**For most public Hugging Face Spaces: NO**
- The default Space (`ved2005-resume-analyzer-demo`) is public and doesn't require authentication
- You can leave `apiToken = null` if you're using a public Space

**You NEED an API key if:**
- The Space requires authentication
- You're using rate-limited endpoints
- You're using a private Space

### Security Best Practices

1. **Never commit your API key to Git**
   - The config file is safe to commit with `null` value
   - Only add your actual token locally

2. **For Production Apps:**
   - Use environment variables
   - Use secure storage services
   - Use Flutter's `flutter_dotenv` package
   - Store keys in secure backend services

3. **Alternative: Environment Variables**

   Create a `.env` file in the project root:
   ```
   HUGGING_FACE_API_TOKEN=hf_your_token_here
   ```

   Then use `flutter_dotenv` package to load it:
   ```dart
   static const String? apiToken = dotenv.env['HUGGING_FACE_API_TOKEN'];
   ```

## Verification

After setting your API key, run the app and check the console output. You should see:
```
✅ Hugging Face API token configured
```

If you see:
```
ℹ️ Hugging Face API token not set (optional - only needed if Space requires authentication)
```

This is also fine - it means the API is working without authentication (using a public Space).

## Troubleshooting

### "API token not working"
- Verify the token is correct (starts with `hf_`)
- Check if the token has the right permissions
- Ensure there are no extra spaces or quotes in the token

### "Service is starting up"
- Hugging Face Spaces can take 30-60 seconds to start (cold start)
- Wait a moment and try again

### "API request failed: 401"
- Your token might be invalid or expired
- Generate a new token from Hugging Face settings

## Configuration File Location

The configuration file is located at:
```
lib/constants/hugging_face_config.dart
```

You can also configure:
- `spaceUrl`: Change the Hugging Face Space URL
- `enabled`: Set to `false` to disable Hugging Face API completely

## Example Configuration

```dart
class HuggingFaceConfig {
  // Your API token (get from https://huggingface.co/settings/tokens)
  static const String? apiToken = 'hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  
  // Space URL (change if using a different Space)
  static const String spaceUrl = 'https://ved2005-resume-analyzer-demo.hf.space';
  
  // Enable/disable Hugging Face API
  static const bool enabled = true;
}
```


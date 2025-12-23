# Troubleshooting 404 Error with Hugging Face API

## Error: `404 - Not Found`

This error means the Hugging Face Space API endpoint cannot be found. Here are the most common causes and solutions:

## Possible Causes

### 1. **Space URL is Incorrect**
The Space might not exist or the URL format is wrong.

**Solution:**
- Verify the Space exists at: https://huggingface.co/spaces/Ved2005/resume-analyzer-demo
- Check if the Space is public or private
- Update the URL in `lib/constants/hugging_face_config.dart` if needed

### 2. **Space API Format Has Changed**
Gradio Spaces can have different API endpoint formats depending on the version.

**Solution:**
The code now tries multiple endpoint formats automatically:
- `/api/predict`
- `/run/predict`
- `/api/queue/push`
- `/run`

### 3. **Space Requires Authentication**
Some Spaces require an API token even if they appear public.

**Solution:**
1. Get your API token from: https://huggingface.co/settings/tokens
2. Set it in `lib/constants/hugging_face_config.dart`:
   ```dart
   static const String? apiToken = 'hf_your_token_here';
   ```

### 4. **Space is Not Deployed or Temporarily Down**
The Space might be offline or not deployed for API access.

**Solution:**
- Check the Space page in your browser
- Try accessing: https://ved2005-resume-analyzer-demo.hf.space
- Wait a few minutes and try again (Spaces can take time to start)

## Quick Fixes

### Option 1: Verify Space URL
1. Open `lib/constants/hugging_face_config.dart`
2. Check the `spaceUrl` value
3. Try accessing the URL in your browser
4. If it doesn't load, the Space might not exist

### Option 2: Use a Different Space
If the current Space doesn't work, you can:
1. Find another resume analyzer Space on Hugging Face
2. Update the `spaceUrl` in the config file
3. Update the API token if needed

### Option 3: Use Local Analysis Only
If Hugging Face API continues to fail, you can disable it:

1. Open `lib/constants/hugging_face_config.dart`
2. Set `enabled = false`:
   ```dart
   static const bool enabled = false;
   ```
3. The app will use local ATS analysis instead

### Option 4: Check API Token Permissions
1. Go to https://huggingface.co/settings/tokens
2. Verify your token has the right permissions
3. Create a new token with "Read" access if needed
4. Update the token in the config file

## Debugging Steps

1. **Check Console Logs**
   - Look for messages like "Checking Space availability"
   - Check what endpoints are being tried
   - Note the exact error messages

2. **Test Space Manually**
   - Open the Space URL in a browser
   - Try uploading a resume manually
   - If it works in browser but not in app, it's an API format issue

3. **Check Network**
   - Ensure you have internet connection
   - Try from a different network
   - Check if firewall is blocking requests

4. **Verify API Format**
   - Different Gradio versions use different API formats
   - The code now tries multiple formats automatically
   - Check console logs to see which formats are attempted

## Alternative: Use Text-Based Analysis

If PDF upload fails, the code automatically falls back to text-based analysis. This sends the resume content as text instead of a file.

## Getting Help

If none of these solutions work:
1. Check the Hugging Face Space page for API documentation
2. Contact the Space creator
3. Check Hugging Face forums for similar issues
4. Consider using a different resume analyzer Space

## Current Configuration

Check your current settings in `lib/constants/hugging_face_config.dart`:

```dart
static const String? apiToken = 'your_token_here'; // or null
static const String spaceUrl = 'https://ved2005-resume-analyzer-demo.hf.space';
static const bool enabled = true;
```

Make sure these values are correct for your setup.


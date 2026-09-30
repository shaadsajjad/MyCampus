/// <reference path="../pb_data/types.d.ts" />

// Configures the `users` verification email to use a custom deep link
// that opens the mobile app directly (mycampus://verify?token={TOKEN}).
// The app handles the deep link, confirms verification with PocketBase,
// and navigates the user to the dashboard.
//
// For local development, the link will still work if the user opens it
// in a browser — they'll see a fallback page instructing them to open the app.
// In production, replace with your actual domain + universal links / app links.
migrate(
  (app) => {
    const settings = app.settings();
    // Base URL for fallback web page (can be a simple static page)
    settings.meta.appURL = 'http://192.168.0.102:8090';
    app.save(settings);

    const users = app.findCollectionByNameOrId('users');
    users.verificationTemplate.subject = 'Verify your {APP_NAME} email';
    users.verificationTemplate.body = `
      <p>Hello,</p>
      <p>Thanks for joining {APP_NAME}. Click the button below to verify your email
      address — you won't be able to log in until you do.</p>
      <p>
        <a class="btn" href="mycampus://verify?token={TOKEN}" target="_blank" rel="noopener">Verify email</a>
      </p>
      <p><i>If the button above doesn't open the app, copy this link and open it in your browser:</i></p>
      <p><small><a href="{APP_URL}/verify-email.html?token={TOKEN}">{APP_URL}/verify-email.html?token={TOKEN}</a></small></p>
      <p><i>If you didn't recently register, please ignore this email.</i></p>
      <p>Thanks,<br/>{APP_NAME} team</p>
    `;
    app.save(users);
  },
  (app) => {
    const settings = app.settings();
    settings.meta.appURL = 'http://localhost:8090';
    app.save(settings);
    // Verification template left as customized; PocketBase has no single
    // "reset to factory default" call, and the exact default text isn't
    // worth hardcoding here just for a down-migration.
  }
);

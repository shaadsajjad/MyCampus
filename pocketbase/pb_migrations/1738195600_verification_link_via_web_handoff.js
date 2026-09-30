/// <reference path="../pb_data/types.d.ts" />

// Most email clients (Gmail included) strip or refuse to act on links with
// a non-http(s) scheme in the email body — an anti-phishing measure — so
// the previous template's `mycampus://verify?token={TOKEN}` button was
// often simply inert when tapped from inside the Gmail app.
//
// Standard fix: make the emailed link a plain http(s) URL (which every
// mail client allows), landing on verify-email.html. That page tries to
// hand off to the app via the custom scheme itself — a JS-triggered
// redirect from an actual browser context works reliably, unlike one
// embedded in mail HTML — and only completes verification in the browser
// if the app doesn't open (app not installed, etc). See pb_public/
// verify-email.html for the handoff/fallback logic.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    users.verificationTemplate.subject = 'Verify your {APP_NAME} email';
    users.verificationTemplate.body = `
      <p>Hello,</p>
      <p>Thanks for joining {APP_NAME}. Click the button below to verify your email
      address — you won't be able to log in until you do.</p>
      <p>
        <a class="btn" href="{APP_URL}/verify-email.html?token={TOKEN}" target="_blank" rel="noopener">Verify email</a>
      </p>
      <p><i>Opening this on your phone switches straight to the {APP_NAME} app
      if it's installed; otherwise it finishes verifying your email right
      here in the browser.</i></p>
      <p><i>If you didn't recently register, please ignore this email.</i></p>
      <p>Thanks,<br/>{APP_NAME} team</p>
    `;
    app.save(users);
  },
  (app) => {
    // No-op down-migration — same reasoning as
    // 1738195500_email_verification.js: there's no single factory-default
    // template to restore to, and the previous custom body isn't worth
    // hardcoding just for a down-migration.
  }
);

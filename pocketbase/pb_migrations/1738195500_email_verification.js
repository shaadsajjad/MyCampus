/// <reference path="../pb_data/types.d.ts" />

// Points the app URL and the `users` verification email at our own static
// confirmation page (served from pb_public/verify-email.html) instead of
// PocketBase's default, which links to the admin UI (`/_/#/auth/confirm-
// verification/{TOKEN}`) — not a page an end user should ever land on.
//
// NOTE: `meta.appURL` is set to the LAN IP so the link is openable from a
// phone on the same Wi-Fi network during local dev. Update it (or move to
// a real domain) for staging/production, and re-run the equivalent update
// via the dashboard if you deploy elsewhere.
migrate(
  (app) => {
    const settings = app.settings();
    settings.meta.appURL = 'http://192.168.0.102:8090';
    app.save(settings);

    const users = app.findCollectionByNameOrId('users');
    users.verificationTemplate.subject = 'Verify your {APP_NAME} email';
    users.verificationTemplate.body = `
      <p>Hello,</p>
      <p>Thanks for joining {APP_NAME}. Click below to verify your email
      address — you won't be able to log in until you do.</p>
      <p>
        <a class="btn" href="{APP_URL}/verify-email.html?token={TOKEN}" target="_blank" rel="noopener">Verify email</a>
      </p>
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

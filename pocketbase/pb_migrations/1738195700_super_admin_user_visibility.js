/// <reference path="../pb_data/types.d.ts" />

// The super admin dashboard needs to count its own university's approved
// students/faculty and pending join requests, which means listing other
// people's `users` records — the default auth-collection rule
// (`id = @request.auth.id`) only lets someone read their own. Widen it so
// a super admin can additionally list/view records in their own
// university, while everyone else keeps self-only access.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    const sameUniversitySuperAdmin =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";
    users.listRule = `id = @request.auth.id || (${sameUniversitySuperAdmin})`;
    users.viewRule = `id = @request.auth.id || (${sameUniversitySuperAdmin})`;
    app.save(users);
  },
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    users.listRule = 'id = @request.auth.id';
    users.viewRule = 'id = @request.auth.id';
    app.save(users);
  }
);

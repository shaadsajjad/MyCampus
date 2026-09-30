/// <reference path="../pb_data/types.d.ts" />

// The join-requests tab needs a super admin to approve/reject other
// people's `users` records (flip `status`), which the default auth
// collection rule (`id = @request.auth.id`) doesn't allow — same gap the
// previous migration closed for listing/viewing. Mirrors that rule for
// `updateRule`: self-update stays allowed, plus a super admin can update
// records in their own university.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    const sameUniversitySuperAdmin =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";
    users.updateRule = `id = @request.auth.id || (${sameUniversitySuperAdmin})`;
    app.save(users);
  },
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    users.updateRule = 'id = @request.auth.id';
    app.save(users);
  }
);

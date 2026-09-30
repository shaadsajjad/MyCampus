/// <reference path="../pb_data/types.d.ts" />

// A notice is its own collection (unlike a join request, which just reuses
// `users.status`) because it's genuinely new data with no existing record
// to piggyback on: a title/body/audience that outlives whoever wrote it.
//
// `audience` picks who a notice is for — `all`, `students`, or `faculty` —
// so a reading screen can filter without a second collection.
//
// Fields/rules are set in a second `app.save()` after the initial create,
// not passed to `new Collection({...})` — on this PocketBase version that
// options object is silently ignored (same issue already hit and fixed for
// `universities`/`students`/`teachers` in
// 1738195400_fix_missing_fields_and_rules.js; confirmed again here against
// pb_data/data.db before writing it this way).
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    const universities = app.findCollectionByNameOrId('universities');

    const notices = new Collection({ name: 'notices', type: 'base' });
    app.save(notices);

    notices.fields.add(new TextField({ name: 'title', required: true, max: 140 }));
    notices.fields.add(new TextField({ name: 'body', required: true, max: 4000 }));
    notices.fields.add(
      new SelectField({
        name: 'audience',
        values: ['all', 'students', 'faculty'],
        maxSelect: 1,
        required: true,
      })
    );
    notices.fields.add(
      new RelationField({
        name: 'university',
        collectionId: universities.id,
        maxSelect: 1,
        required: true,
      })
    );
    notices.fields.add(
      new RelationField({
        name: 'author',
        collectionId: users.id,
        maxSelect: 1,
        required: true,
      })
    );

    // Read: any signed-in member of the same university (once
    // students/teachers actually have `university` set — see
    // pocketbase_schema.md). Write: only a super admin, for their own
    // university, and only the author may update/delete their own post.
    // The record's own field goes first in each comparison — PocketBase's
    // rule parser resolves a bare field name against whichever side of
    // `=` it's on, so `@request.auth.x = y` looks up `y` as a field on
    // `users` (the auth collection) instead of on `notices`.
    notices.listRule = 'university = @request.auth.university';
    notices.viewRule = 'university = @request.auth.university';
    notices.createRule =
      "author = @request.auth.id && university = @request.auth.university && @request.auth.role = 'superAdmin'";
    notices.updateRule = 'author = @request.auth.id';
    notices.deleteRule = 'author = @request.auth.id';

    app.save(notices);
  },
  (app) => {
    const notices = app.findCollectionByNameOrId('notices');
    app.delete(notices);
  }
);

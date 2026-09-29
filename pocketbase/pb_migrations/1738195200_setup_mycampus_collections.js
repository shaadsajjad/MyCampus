/// <reference path="../pb_data/types.d.ts" />

// Adds the MyCampus-specific fields to the built-in `users` collection and
// creates the `universities` collection. Field names/options here must
// match `lib/features/auth/data/repositories/auth_repository_impl.dart`
// exactly — see `pocketbase_schema.md` at the repo root for the full
// reference table.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');

    users.fields.add(
      new SelectField({
        name: 'role',
        values: ['superAdmin', 'faculty', 'student'],
        maxSelect: 1,
      })
    );
    users.fields.add(
      new SelectField({
        name: 'status',
        values: ['pending', 'approved', 'rejected'],
        maxSelect: 1,
      })
    );
    users.fields.add(new TextField({ name: 'phone' }));
    users.fields.add(new TextField({ name: 'studentId' }));
    users.fields.add(new TextField({ name: 'department' }));
    users.fields.add(new TextField({ name: 'batch' }));
    users.fields.add(new TextField({ name: 'teacherId' }));
    users.fields.add(
      new SelectField({
        name: 'designation',
        values: [
          'professor',
          'associateProfessor',
          'assistantProfessor',
          'lecturer',
        ],
        maxSelect: 1,
      })
    );

    app.save(users);

    const universities = new Collection({
      name: 'universities',
      type: 'base',
      fields: [
        new TextField({ name: 'name', required: true }),
        new TextField({ name: 'shortName', required: true }),
        new SelectField({
          name: 'type',
          values: ['public', 'private', 'international'],
          maxSelect: 1,
        }),
        new TextField({ name: 'city', required: true }),
        new TextField({ name: 'country', required: true }),
        new DateField({ name: 'establishedAt' }),
        new FileField({ name: 'logo', maxSelect: 1 }),
        new RelationField({
          name: 'admin',
          collectionId: users.id,
          maxSelect: 1,
          required: true,
        }),
      ],
      // Public create: the super-admin registration flow creates this
      // record before the new admin is authenticated. Tighten this once
      // there's a reason to (e.g. once registration goes through a
      // server-side hook instead of two client-side writes).
      createRule: '',
      listRule: '',
      viewRule: '',
    });

    app.save(universities);

    // `users.university` is a relation to `universities`, which didn't
    // exist yet when `users` was first saved above.
    const usersAgain = app.findCollectionByNameOrId('users');
    usersAgain.fields.add(
      new RelationField({
        name: 'university',
        collectionId: universities.id,
        maxSelect: 1,
      })
    );
    app.save(usersAgain);
  },
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    [
      'role',
      'status',
      'phone',
      'studentId',
      'department',
      'batch',
      'teacherId',
      'designation',
      'university',
    ].forEach((name) => users.fields.removeByName(name));
    app.save(users);

    const universities = app.findCollectionByNameOrId('universities');
    app.delete(universities);
  }
);

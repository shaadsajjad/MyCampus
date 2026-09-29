/// <reference path="../pb_data/types.d.ts" />

// Moves role-specific fields off the built-in `users` collection (which
// should only hold basic account info) and into dedicated `students` and
// `teachers` collections, each linked back to `users` via a `user`
// relation. `users` keeps: role, status, phone, university (added by the
// previous migration) plus the built-in email/name/avatar.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');
    ['studentId', 'department', 'batch', 'teacherId', 'designation'].forEach(
      (name) => users.fields.removeByName(name)
    );
    app.save(users);

    const students = new Collection({
      name: 'students',
      type: 'base',
      fields: [
        new RelationField({
          name: 'user',
          collectionId: users.id,
          maxSelect: 1,
          required: true,
        }),
        new TextField({ name: 'studentId', required: true }),
        new TextField({ name: 'department' }),
        new TextField({ name: 'batch' }),
      ],
      // Public create: this is written right after the matching `users`
      // record, before that account is authenticated. Same simplification
      // as `universities` — see pocketbase_schema.md.
      createRule: '',
      listRule: '',
      viewRule: '',
    });
    app.save(students);

    const teachers = new Collection({
      name: 'teachers',
      type: 'base',
      fields: [
        new RelationField({
          name: 'user',
          collectionId: users.id,
          maxSelect: 1,
          required: true,
        }),
        new TextField({ name: 'teacherId', required: true }),
        new TextField({ name: 'department' }),
        new SelectField({
          name: 'designation',
          values: [
            'professor',
            'associateProfessor',
            'assistantProfessor',
            'lecturer',
          ],
          maxSelect: 1,
        }),
      ],
      createRule: '',
      listRule: '',
      viewRule: '',
    });
    app.save(teachers);
  },
  (app) => {
    app.delete(app.findCollectionByNameOrId('teachers'));
    app.delete(app.findCollectionByNameOrId('students'));

    const users = app.findCollectionByNameOrId('users');
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
  }
);

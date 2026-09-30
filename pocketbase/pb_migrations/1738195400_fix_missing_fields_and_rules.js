/// <reference path="../pb_data/types.d.ts" />

// Corrective migration: the two prior migrations created `universities`,
// `students`, and `teachers` via `new Collection({ fields: [...],
// createRule: '', ... })`, but that options object is silently ignored on
// this PocketBase version — only `id` and no rules ended up on any of the
// three. Confirmed directly against pb_data/data.db before writing this.
// Fields and rules must be set the same way it already worked for
// `users`: fetch the collection, mutate it, then `app.save()`.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId('users');

    const universities = app.findCollectionByNameOrId('universities');
    universities.fields.add(new TextField({ name: 'name', required: true }));
    universities.fields.add(
      new TextField({ name: 'shortName', required: true })
    );
    universities.fields.add(
      new SelectField({
        name: 'type',
        values: ['public', 'private', 'international'],
        maxSelect: 1,
      })
    );
    universities.fields.add(new TextField({ name: 'city', required: true }));
    universities.fields.add(
      new TextField({ name: 'country', required: true })
    );
    universities.fields.add(new DateField({ name: 'establishedAt' }));
    universities.fields.add(new FileField({ name: 'logo', maxSelect: 1 }));
    universities.fields.add(
      new RelationField({
        name: 'admin',
        collectionId: users.id,
        maxSelect: 1,
        required: true,
      })
    );
    universities.createRule = '';
    universities.listRule = '';
    universities.viewRule = '';
    app.save(universities);

    const students = app.findCollectionByNameOrId('students');
    students.fields.add(
      new RelationField({
        name: 'user',
        collectionId: users.id,
        maxSelect: 1,
        required: true,
      })
    );
    students.fields.add(new TextField({ name: 'studentId', required: true }));
    students.fields.add(new TextField({ name: 'department' }));
    students.fields.add(new TextField({ name: 'batch' }));
    students.createRule = '';
    students.listRule = '';
    students.viewRule = '';
    app.save(students);

    const teachers = app.findCollectionByNameOrId('teachers');
    teachers.fields.add(
      new RelationField({
        name: 'user',
        collectionId: users.id,
        maxSelect: 1,
        required: true,
      })
    );
    teachers.fields.add(new TextField({ name: 'teacherId', required: true }));
    teachers.fields.add(new TextField({ name: 'department' }));
    teachers.fields.add(
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
    teachers.createRule = '';
    teachers.listRule = '';
    teachers.viewRule = '';
    app.save(teachers);
  },
  (app) => {
    ['universities', 'students', 'teachers'].forEach((name) => {
      const collection = app.findCollectionByNameOrId(name);
      collection.createRule = null;
      collection.listRule = null;
      collection.viewRule = null;
      app.save(collection);
    });
  }
);

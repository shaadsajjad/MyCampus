/// <reference path="../pb_data/types.d.ts" />

// The course catalogue a university teaches — the thing a routine gets
// built out of later. This is genuinely new data (a course isn't a `users`
// row or a status flip), so like `notices` it gets its own collection.
//
// `code` is the identifier a timetable shows (e.g. `CSE-101`). Uniqueness is
// enforced in the app, not here: a PocketBase unique index on `code` alone
// would be record-scoped rather than university-scoped, and would wrongly
// stop two different campuses from each teaching `CSE-101`. See
// `CoursesRepositoryImpl.createCourse` — it lists the university's courses
// and rejects a duplicate itself. If this ever moves into the database, it
// has to be a compound unique on (university, code).
//
// `credits` and `contactHours` are deliberately separate: a 4-credit course
// commonly meets 3× a week, and a routine has to fit the contact hours, not
// the credit count.
//
// `created`/`updated` are added explicitly rather than assumed. On this
// PocketBase version a base collection doesn't get them for free — the same
// issue already hit and fixed for `notices` in
// 1738196000_notices_created_updated.js, confirmed against pb_data/data.db.
// `courses_remote_datasource.dart` sorts by `code`, but omitting them would
// leave the collection inconsistent with every other one in the project.
//
// Fields/rules are set in a second `app.save()` after the initial create,
// not passed to `new Collection({...})` — on this PocketBase version that
// options object is silently ignored (same issue as `universities`/
// `students`/`teachers` in 1738195400_fix_missing_fields_and_rules.js and
// `notices` in 1738195900_notices_collection.js).
migrate(
  (app) => {
    const universities = app.findCollectionByNameOrId('universities');

    const courses = new Collection({ name: 'courses', type: 'base' });
    app.save(courses);

    courses.fields.add(
      new TextField({ name: 'code', required: true, max: 32 })
    );
    courses.fields.add(
      new TextField({ name: 'title', required: true, max: 140 })
    );
    // onlyInt keeps these whole numbers — the app already validates 1–20 on
    // both sides, so this is the same rule enforced where it can't be
    // bypassed by a hand-rolled API call.
    courses.fields.add(
      new NumberField({
        name: 'credits',
        required: true,
        onlyInt: true,
        min: 1,
        max: 20,
      })
    );
    courses.fields.add(
      new NumberField({
        name: 'contactHours',
        required: true,
        onlyInt: true,
        min: 1,
        max: 20,
      })
    );
    // Free text, matching `students.department`/`teachers.department` — see
    // the note in pocketbase_schema.md about those not being a relation yet.
    courses.fields.add(new TextField({ name: 'department', max: 120 }));
    courses.fields.add(
      new RelationField({
        name: 'university',
        collectionId: universities.id,
        maxSelect: 1,
        required: true,
      })
    );
    courses.fields.add(
      new AutodateField({ name: 'created', onCreate: true })
    );
    courses.fields.add(
      new AutodateField({ name: 'updated', onCreate: true, onUpdate: true })
    );

    // Read: any signed-in member of the same university (once
    // students/teachers actually have `university` set — see
    // pocketbase_schema.md). Write: only a super admin, and only for their
    // own university — so one admin can maintain their own catalogue but
    // never another campus's.
    //
    // Note the field order: PocketBase's rule parser resolves a bare field
    // name against whichever side of `=` it's on, so the record's own field
    // always goes first (same trap as `notices`).
    courses.listRule = 'university = @request.auth.university';
    courses.viewRule = 'university = @request.auth.university';
    courses.createRule =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";
    courses.updateRule =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";
    courses.deleteRule =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";

    app.save(courses);
  },
  (app) => {
    const courses = app.findCollectionByNameOrId('courses');
    app.delete(courses);
  }
);

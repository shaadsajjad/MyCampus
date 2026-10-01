/// <reference path="../pb_data/types.d.ts" />

// The weekly timetable a super admin builds out of the `courses`
// catalogue — one slot is "this course meets on this day, in this time
// window". Nothing here assigns a slot to a specific teacher or section
// cohort yet; see the `routine` entry in `clean_architecture.md`'s
// Feature map for what's deliberately out of scope for v1.
//
// `dayOfWeek` is a Select rather than a Number so the value is readable in
// the PocketBase dashboard, matching every other enum-backed field in this
// project. Its values must equal `DayOfWeek.name`
// (`lib/core/domain/entities/day_of_week.dart`) exactly — same convention
// already documented for `UserRole`/`AccountStatus`/etc. PocketBase sorts
// Select values alphabetically, which isn't calendar order, so day
// grouping happens client-side (`RoutineRepositoryImpl.getWeeklyRoutine`)
// rather than via a `sort` param here.
//
// `startTime`/`endTime` are Text, not a native time field (PocketBase has
// none) — zero-padded 24h `HH:mm` sorts correctly as a plain string.
//
// `course`/`university` are both direct relations (not just `course`,
// joined through to its university) so the API rules below can filter on
// a plain top-level field, the same reason `courses` itself duplicates
// `university` rather than relying only on `code`.
//
// Fields/rules are set in a second `app.save()` after the initial create,
// not passed to `new Collection({...})` — same PocketBase-version quirk
// already noted in `1738196100_courses_collection.js`.
migrate(
  (app) => {
    const courses = app.findCollectionByNameOrId('courses');
    const universities = app.findCollectionByNameOrId('universities');

    const routine = new Collection({ name: 'routine', type: 'base' });
    app.save(routine);

    routine.fields.add(
      new RelationField({
        name: 'course',
        collectionId: courses.id,
        maxSelect: 1,
        required: true,
      })
    );
    routine.fields.add(
      new RelationField({
        name: 'university',
        collectionId: universities.id,
        maxSelect: 1,
        required: true,
      })
    );
    routine.fields.add(
      new SelectField({
        name: 'dayOfWeek',
        values: [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday',
        ],
        maxSelect: 1,
        required: true,
      })
    );
    routine.fields.add(
      new TextField({ name: 'startTime', required: true, max: 5 })
    );
    routine.fields.add(
      new TextField({ name: 'endTime', required: true, max: 5 })
    );
    routine.fields.add(new TextField({ name: 'room', max: 60 }));
    routine.fields.add(new TextField({ name: 'section', max: 60 }));
    routine.fields.add(
      new AutodateField({ name: 'created', onCreate: true })
    );
    routine.fields.add(
      new AutodateField({ name: 'updated', onCreate: true, onUpdate: true })
    );

    // Read: any signed-in member of the same university. Write: only a
    // super admin, and only for their own university — same shape as
    // `courses`. Note the field order: the record's own field always goes
    // first (see `courses`' rule comment for why).
    routine.listRule = 'university = @request.auth.university';
    routine.viewRule = 'university = @request.auth.university';
    routine.createRule =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";
    routine.updateRule =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";
    routine.deleteRule =
      "@request.auth.role = 'superAdmin' && university = @request.auth.university";

    app.save(routine);
  },
  (app) => {
    const routine = app.findCollectionByNameOrId('routine');
    app.delete(routine);
  }
);

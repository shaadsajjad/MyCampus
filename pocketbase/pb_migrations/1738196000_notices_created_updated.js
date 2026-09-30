/// <reference path="../pb_data/types.d.ts" />

// `notices_remote_datasource.dart` sorts by `-created`, but
// 1738195900_notices_collection.js never added `created`/`updated` fields
// — on this PocketBase version a base collection doesn't get them for
// free, they have to be added explicitly as AutodateField (confirmed:
// `universities`/`students`/`teachers` are missing them too, but nothing
// sorts by those yet so it went unnoticed). Without this, listing notices
// fails with "invalid sort field \"created\"".
migrate(
  (app) => {
    const notices = app.findCollectionByNameOrId('notices');
    notices.fields.add(
      new AutodateField({ name: 'created', onCreate: true })
    );
    notices.fields.add(
      new AutodateField({ name: 'updated', onCreate: true, onUpdate: true })
    );
    app.save(notices);
  },
  (app) => {
    const notices = app.findCollectionByNameOrId('notices');
    notices.fields.removeByName('created');
    notices.fields.removeByName('updated');
    app.save(notices);
  }
);

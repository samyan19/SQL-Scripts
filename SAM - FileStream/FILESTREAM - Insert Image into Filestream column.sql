INSERT INTO PhotoAlbum(PhotoId, Description, Photo)
 VALUES(2, 'Document icon',
  (SELECT BulkColumn FROM OPENROWSET(BULK '\\public\shared\doc.ico', SINGLE_BLOB) AS x)
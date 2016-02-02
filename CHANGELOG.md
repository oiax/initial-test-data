# CHANGELOG - initial-test-data

## 0.4.4 (February 2, 2016)

* Truncate only non-empty tables (optimization).

## 0.4.3 (February 2, 2016)

* Covert RECORD_IDS to a regular hash before save.

## 0.4.2 (February 2, 2016)

* Include `*.yml` to the target file list of md5 digest generation.

## 0.4.1 (February 2, 2016)

* Add `as` option to the `store` utility method.

## 0.4.0 (February 1, 2016)

* Introduce utility methods `store` and `fetch`.

## 0.3.0 (January 31, 2016)

* Monitor `app/models/**/*.rb`. When any modification is detected,
reinitialize the test data.
* The class method `InitialTestData.load` accepts `monitoring` option
to add the target directories of monitoring.

## 0.2.1 (January 31, 2016)

* Fix bug that the `_initial_data_digest` table gets truncated.

## 0.2.0 (January 31, 2016)

* The class method `InitialTestData.load` treats the last hash argument
as the options for `DatabaseCleaner.strategy=` method.

## 0.1.0 (January 31, 2016)

* The first release with minimum functionalities.

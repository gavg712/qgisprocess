
test_that("qgis_run_algorithm() works", {
  skip_if_not(has_qgis())
  skip_if_offline()

  tmp_json <- qgis_tmp_file(".json")
  result <- expect_output(
    qgis_run_algorithm("native:filedownloader", URL = "https://httpbin.org/get", OUTPUT = tmp_json, .quiet = FALSE),
    "^Running\\s+"
  )
  expect_true(file.exists(tmp_json))

  unlink(tmp_json)
  result <- expect_silent(
    qgis_run_algorithm("native:filedownloader", URL = "https://httpbin.org/get", OUTPUT = tmp_json, .quiet = TRUE)
  )
  expect_true(file.exists(tmp_json))
})

test_that("qgis_run_algorithm() ignores unknown inputs", {
  skip_if_not(has_qgis())

  expect_message(
    qgis_run_algorithm(
      "native:buffer",
      NOT_AN_INPUT = "some value",
      INPUT = system.file("longlake/longlake.gpkg", package = "qgisprocess"),
      DISTANCE = 100,
      .quiet = TRUE
    ),
    "Ignoring unknown input"
  )
})

test_that("qgis_run_algorithm accepts multipleinput arguments", {
  skip_if_not(has_qgis())
  skip_if_not_installed("sf")
  skip("Requires recent QGIS")

  v_1 = sf::read_sf(
    system.file("longlake/longlake.gpkg", package = "qgisprocess"))
  v_2 = v_3 = v_1
  v_2$geom = v_2$geom + 1000
  sf::st_crs(v_2) = sf::st_crs(v_1)
  v_3$geom = v_3$geom - 1000
  sf::st_crs(v_3) = sf::st_crs(v_1)
  out = qgis_run_algorithm("native:mergevectorlayers",
                           LAYERS = v_1, LAYERS = v_2, LAYERS = v_3,
                           .quiet = TRUE)
  tmp = sf::read_sf(qgis_output(out, "OUTPUT"))
  expect_equal(nrow(tmp), 3)
})

test_that("qgis_has_algorithm() works", {
  skip_if_not(has_qgis())
  expect_true(qgis_has_algorithm("native:filedownloader"))
  expect_false(qgis_has_algorithm("notanalgorithm"))
})

test_that("qgis_has_provider() works", {
  skip_if_not(has_qgis())
  expect_true(qgis_has_provider("native"))
  expect_false(qgis_has_provider("notaprovider"))
})

test_that("qgis_providers() works", {
  skip_if_not(has_qgis())
  expect_true("native" %in% qgis_providers()$provider)
  expect_false("notaprovider" %in% qgis_providers()$provider)
})

test_that("assert_qgis_algorithm() works", {
  skip_if_not(has_qgis())
  expect_error(assert_qgis_algorithm("notanalgorithm"))
  expect_identical(assert_qgis_algorithm("native:filedownloader"), "native:filedownloader")
})

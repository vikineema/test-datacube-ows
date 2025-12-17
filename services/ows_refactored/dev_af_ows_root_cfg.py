ows_cfg = {
    "global": {
        # Configuration to the whole server across all supported services goes here.
        # "env": "default",
        # Internationalisation
        "message_domain": "ows_cfg",
        "translations_directory": "/env/config/ows_refactored/translations",
        "supported_languages": [
            "en",  # English  - the default language, the language used in the untranslated metadata.
            "fr",  # French
        ],
        # Metadata to go straight into GetCapabilities documents
        "title": "Digital Earth Africa - OGC Web Services",
        "info_url": "digitalearthafrica.org/",
        "services": {
            "wms": True,
            "wcs": True,
            "wmts": True,
        },
        "response_headers": {
            "Access-Control-Allow-Origin": "*",
        },
        "allowed_urls": [
            # Common local dev URLs
            # "http://localhost",
            # ?internal port or external
            "http://localhost:8083",
            # "http://localhost:8083/"
        ],
        "published_CRSs": {
            "EPSG:3857": {  # Web Mercator
                "geographic": False,
                "horizontal_coord": "x",
                "vertical_coord": "y",
            },
            "EPSG:4326": {"geographic": True, "vertical_coord_first": True},  # WGS-84
            "EPSG:6933": {  # Cylindrical equal area
                "geographic": False,
                "horizontal_coord": "x",
                "vertical_coord": "y",
            },
        },
        "abstract": """Digital Earth Africa OGC Web Services""",
        "keywords": [
            "landsat",
            "africa",
            "WOfS",
            "fractional-cover",
            "time-series",
        ],
        "contact_info": {
            "person": "Digital Earth Africa",
            "organisation": "Digital Earth Africa",
            "position": "",
            "address": {
                "type": "postal",
                "address": "GPO Box 378",
                "city": "Canberra",
                "state": "ACT",
                "postcode": "2609",
                "country": "Australia",
            },
            "telephone": "+61 2 6249 9111",
            "fax": "",
            "email": "info@digitalearthafrica.org",
        },
        "fees": "",
        # TODO: Is this access constraints appropriate for DEA?
        "access_constraints": "© Commonwealth of Australia (Geoscience Australia) 2018. "
        "This product is released under the Creative Commons Attribution 4.0 International Licence. "
        "http://creativecommons.org/licenses/by/4.0/legalcode",
    },
    "wms": {
        # Configuration specific to the WMS and WMTS services goes here.
        #  for all products/layers
        "max_width": 512,
        "max_height": 512,
        "s3_aws_zone": "af-south-1",
    },
    "wmts": {
        # Configuration specific to the WMTS service goes here.
    },
    "wcs": {
        # Configuration specific to the WCS service goes here.
        "formats": {
            # Key is the format name, as used in DescribeCoverage XML
            "GeoTIFF": {
                "renderers": {
                    "1": "datacube_ows.wcs1_utils.get_tiff",
                    "2": "datacube_ows.wcs2_utils.get_tiff",
                },
                # The MIME type of the image, as used in the Http Response.
                "mime": "image/geotiff",
                # The file extension to add to the filename.
                "extension": "tif",
                # Whether or not the file format supports multiple time slices.
                "multi-time": False,
            },
            "netCDF": {
                "renderers": {
                    "1": "datacube_ows.wcs1_utils.get_netcdf",
                    "2": "datacube_ows.wcs2_utils.get_netcdf",
                },
                "mime": "application/x-netcdf",
                "extension": "nc",
                "multi-time": True,
            },
        },
        "native_format": "GeoTIFF",
    },
    "layers": [
        {
            "title": "Digital Earth Africa - OGC Web Services",
            "abstract": "Digital Earth Africa OGC Web Services",
            "layers": [
                # A list of configurations for layers (WMS/WMTS) (or coverages (WCS)) to be served.
                {
                    "title": "DE Africa Continental Services",
                    "abstract": """DE Africa Continental Services""",
                    "layers": [
                        {
                            "title": "Surface water",
                            "abstract": """Surface water""",
                            "layers": [
                                {
                                    "include": "ows_refactored.water_quality.ows_wq_annual_cfg.layer",
                                    "type": "python",
                                },
                            ],
                        }
                    ],
                }
            ],
        }
    ],
}

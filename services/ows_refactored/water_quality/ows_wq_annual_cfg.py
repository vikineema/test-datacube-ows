from ows_refactored.common.ows_reslim_cfg import reslim_continental
from ows_refactored.water_quality.style_wq_annual_cfg import style_wq_annual_tsm

layer = {
    "title": "Annual Water Quality Variables",
    "abstract": """Annual Water Quality Variables""",
    "name": "wq_annual",
    "product_name": "wq_annual",
    "multi_product": False,
    "time_resolution": "summary",
    "default_time": "latest",
    "bands": {
        "tsm": [],
    },
    "native_crs": "EPSG:6933",
    "native_resolution": [10.0, 10.0],
    "resource_limits": reslim_continental,
    "image_processing": {
        "extent_mask_func": "datacube_ows.ogc_utils.mask_by_val",
        "always_fetch_bands": [],
        "fuse_func": None,
        "manual_merge": False,
    },
    "styling": {"default_style": "wq_annual_tsm", "styles": [style_wq_annual_tsm]},
}

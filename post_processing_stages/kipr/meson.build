kipr_postprocessing_src = files([
    # Base stage
    'kipr_post_processing_stage.cpp',
    # Object detection
    'kipr_object_detection.cpp',
    # Posenet
    'kipr_posenet.cpp',
])

postproc_assets += files([
    assets_dir / 'kipr_mobilenet_ssd.json',
    assets_dir / 'kipr_posenet.json',
])

kipr_postprocessing_lib = shared_module('kipr-postproc', kipr_postprocessing_src,
                                          dependencies : libcamera_dep,
                                          include_directories : '../..',
                                          install : true,
                                          install_dir : posproc_libdir,
                                          name_prefix : '',
                                         )


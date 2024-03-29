



#' @title write_giotto_viewer_annotation
#' @description write out factor-like annotation data from a giotto object for the Viewer
#' @param annotation annotation from the data.table from giotto object
#' @param annot_name name of the annotation
#' @param output_directory directory where to save the files
#' @return write a .txt and .annot file for the selection annotation
#' @keywords internal
write_giotto_viewer_annotation = function(annotation,
                                          annot_name = 'test',
                                          output_directory = getwd()) {

  if(is.numeric(annotation) == TRUE) {

    # annotation information and mapping
    sorted_unique_numbers = sort(unique(annotation))
    annot_map = data.table::data.table(num = sorted_unique_numbers, fac = sorted_unique_numbers)
    annot_information = annotation

  } else {

    # factors to numerics
    uniq_factors = unique(annotation)
    uniq_numerics = 1:length(uniq_factors)

    # create converter
    uniq_factor_num_converter = uniq_numerics
    names(uniq_factor_num_converter) = uniq_factors

    # annotation information and mapping
    annot_map = data.table::data.table(num = uniq_numerics, fac = uniq_factors)
    annot_information = uniq_factor_num_converter[annotation]

  }



  # write to output directory
  annot_inf_name = paste0(annot_name,'_annot_information','.txt')
  write.table(annot_information, file = paste0(output_directory,'/', annot_inf_name),
              quote = F, row.names = F, col.names = F, sep = ' ')

  annot_inf_map = paste0(annot_name,'_annot_information','.annot')
  write.table(annot_map,file = paste0(output_directory,'/', annot_inf_map),
              quote = F, row.names = F, col.names = F, sep = '\t')

}



#' @title write_giotto_viewer_numeric_annotation
#' @description write out numeric annotation data from a giotto object for the Viewer
#' @param annotation annotation from the data.table from giotto object
#' @param annot_name name of the annotation
#' @param output_directory directory where to save the files
#' @return write a .txt and .annot file for the selection annotation
#' @keywords internal
write_giotto_viewer_numeric_annotation = function(annotation,
                                                  annot_name = 'test',
                                                  output_directory = getwd()) {

  # write to output directory
  annot_inf_map = paste0(annot_name,'_num_annot_information','.txt')
  write.table(annotation,file = paste0(output_directory,'/', annot_inf_map),
              quote = F, row.names = F, col.names = F, sep = '\t')

}





#' @title write_giotto_viewer_dim_reduction
#' @description write out dimensional reduction data from a giotto object for the Viewer
#' @param dim_reduction_cell dimension reduction slot from giotto object
#' @param dim_red high level name of dimension reduction
#' @param dim_red_name specific name of dimension reduction to use
#' @param dim_red_rounding numerical indicating how to round the coordinates
#' @param dim_red_rescale numericals to rescale the coordinates
#' @param output_directory directory where to save the files
#' @return write a .txt and .annot file for the selection annotation
#' @keywords internal
write_giotto_viewer_dim_reduction = function(dim_reduction_cell,
                                             dim_red = NULL,
                                             dim_red_name = NULL,
                                             dim_red_rounding = NULL,
                                             dim_red_rescale = c(-20,20),
                                             output_directory = getwd()) {


  dim_red_coord = dim_reduction_cell[[dim_red]][[dim_red_name]]$coordinates[,1:2]

  if(is.null(dim_red_coord)) {
    cat('\n combination of ', dim_red, ' and ', dim_red_name, ' does not exist \n')
  } else {

    # round dimension reduction coordinates
    if(!is.null(dim_red_rounding) & is.integer(dim_red_rounding)) {
      dim_red_coord = round(dim_red_coord, digits = dim_red_rounding)
    }

    # rescale dimension reduction coordinates
    if(!is.null(dim_red_rescale) & length(dim_red_rescale) == 2) {
      dim_red_coord = scales::rescale(x = dim_red_coord, to = dim_red_rescale)
    }

    dim_red_name = paste0(dim_red,'_',dim_red_name,'_dim_coord.txt')
    write.table(dim_red_coord, file = paste0(output_directory,'/', dim_red_name),
                quote = F, row.names = F, col.names = F, sep = ' ')

  }
}



#' @title exportGiottoViewer
#' @name exportGiottoViewer
#' @description compute highly variable genes
#' @param gobject giotto object
#' @param feat_type feature types
#' @param spat_loc_name name of spatial locations to export
#' @param output_directory directory where to save the files
#' @param spat_enr_names spatial enrichment results to include for annotations
#' @param factor_annotations giotto cell annotations to view as factor
#' @param numeric_annotations giotto cell annotations to view as numeric
#' @param dim_reductions high level dimension reductions to view
#' @param dim_reduction_names specific dimension reduction names
#' @param expression_values expression values to use in Viewer
#' @param dim_red_rounding numerical indicating how to round the coordinates
#' @param dim_red_rescale numericals to rescale the coordinates
#' @param expression_rounding numerical indicating how to round the expression data
#' @param overwrite_dir overwrite files in the directory if it already existed
#' @param verbose be verbose
#' @return writes the necessary output to use in Giotto Viewer
#' @details Giotto Viewer expects the results from Giotto Analyzer in a specific format,
#' which is provided by this function. To include enrichment results from {\code{\link{createSpatialEnrich}}}
#' include the provided spatial enrichment name (default PAGE or rank)
#' and add the gene signature names (.e.g cell types) to the numeric annotations parameter.
#' @export
#' @examples
#'
#' \dontrun{
#'
#' data(mini_giotto_single_cell)
#' exportGiottoViewer(mini_giotto_single_cell)
#'
#' }
#'
exportGiottoViewer = function(gobject,
                              feat_type = NULL,
                              spat_loc_name = 'raw',
                              output_directory = NULL,
                              spat_enr_names = NULL,
                              factor_annotations = NULL,
                              numeric_annotations = NULL,
                              dim_reductions,
                              dim_reduction_names,
                              expression_values = c('scaled', 'normalized', 'custom'),
                              dim_red_rounding = NULL,
                              dim_red_rescale = c(-20,20),
                              expression_rounding = 2,
                              overwrite_dir = TRUE,
                              verbose = T) {

  ## output directory ##
  if(file.exists(output_directory)) {
    if(overwrite_dir == TRUE) {
      cat('\n output directory already exists, files will be overwritten \n')
    } else {
      stop('\n output directory already exists, change overwrite_dir = TRUE to overwrite files \n')
    }
  } else if(is.null(output_directory)) {
    cat('\n no output directory is provided, defaults to current directory: ', getwd(), '\n')
    output_directory = getwd()
  } else {
    cat('output directory is created \n')
    dir.create(output_directory, recursive = T)
  }


  # set feat type
  if(is.null(feat_type)) {
    feat_type = gobject@expression_feat[[1]]
  }


  if(verbose == TRUE) cat('\n write cell and gene IDs \n')

  ### output cell_IDs ###
  giotto_cell_ids = gobject@cell_ID
  write.table(giotto_cell_ids, file = paste0(output_directory,'/','giotto_cell_ids.txt'),
              quote = F, row.names = F, col.names = F, sep = ' ')

  ### output all feat_IDs ###
  possible_feat_types =  names(gobject@feat_ID)
  feat_type = feat_type[feat_type %in% possible_feat_types]

  for(feat in feat_type) {
    giotto_feat_ids = gobject@feat_ID[[feat]]
    write.table(giotto_feat_ids, file = paste0(output_directory,'/','giotto_',feat,'_ids.txt'),
                quote = F, row.names = F, col.names = F, sep = ' ')
  }


  ### physical location ###
  if(verbose == TRUE) cat('write physical centroid locations\n')

  # data.table variables
  sdimx = sdimy = NULL
  spatial_location = get_spatial_locations(gobject = gobject,
                                           spat_loc_name = spat_loc_name)
  spatial_location = spatial_location[, .(sdimx, sdimy)]
  write.table(spatial_location, file = paste0(output_directory,'/','centroid_locations.txt'),
              quote = F, row.names = F, col.names = F, sep = ' ')

  ### offset file ###
  offset_file = gobject@offset_file
  if(!is.null(offset_file)) {
    if(verbose == TRUE) cat('write offset file \n')
    write.table(offset_file, file = paste0(output_directory,'/','offset_file.txt'),
                quote = F, row.names = F, col.names = F, sep = ' ')
  }



  ### annotations ###
  for(feat in feat_type) {


    if(verbose == TRUE) cat('\n for feature type ', feat, ' do: ','\n')

    cell_metadata = combineMetadata(gobject = gobject,
                                    feat_type = feat,
                                    spat_enr_names = spat_enr_names)


    # factor annotations #
    if(!is.null(factor_annotations)) {
      found_factor_annotations = factor_annotations[factor_annotations %in% colnames(cell_metadata)]

      for(sel_annot in found_factor_annotations) {

        if(verbose == TRUE) cat('\n write annotation data for: ', sel_annot,'\n')

        selected_annotation = cell_metadata[[sel_annot]]
        write_giotto_viewer_annotation(annotation = selected_annotation,
                                       annot_name = paste0(feat,'_', sel_annot),
                                       output_directory = output_directory)

      }

      # annotiation list #
      text_file_names = list()
      annot_names = list()
      for(sel_annot_id in 1:length(found_factor_annotations)) {

        sel_annot_name = found_factor_annotations[sel_annot_id]
        annot_inf_name = paste0(sel_annot_name,'_annot_information.txt')

        annot_names[[sel_annot_id]] = sel_annot_name
        text_file_names[[sel_annot_id]] = annot_inf_name

      }

      annot_list = data.table(txtfiles = unlist(text_file_names), names = unlist(annot_names))
      write.table(annot_list, file = paste0(output_directory,'/','annotation_list','_',feat, '.txt'),
                  quote = F, row.names = F, col.names = F, sep = ' ')
    }



    # numeric annotations #
    if(!is.null(numeric_annotations)) {
      found_numeric_annotations = numeric_annotations[numeric_annotations %in% colnames(cell_metadata)]
      for(sel_annot in found_numeric_annotations) {

        if(verbose == TRUE) cat('\n write annotation data for: ', sel_annot,'\n')
        selected_annotation = cell_metadata[[sel_annot]]
        write_giotto_viewer_numeric_annotation(annotation = selected_annotation,
                                               annot_name = paste0(feat,'_', sel_annot),
                                               output_directory = output_directory)

      }



      # numeric annotiation list #
      text_file_names = list()
      annot_names = list()
      for(sel_annot_id in 1:length(found_numeric_annotations)) {

        sel_annot_name = found_numeric_annotations[sel_annot_id]
        annot_inf_name = paste0(sel_annot_name,'_num_annot_information.txt')

        annot_names[[sel_annot_id]] = sel_annot_name
        text_file_names[[sel_annot_id]] = annot_inf_name

      }

      annot_list = data.table(txtfiles = unlist(text_file_names), names = unlist(annot_names))
      write.table(annot_list, file = paste0(output_directory,'/','annotation_num_list','_',feat, '.txt'),
                  quote = F, row.names = F, col.names = F, sep = ' ')
    }


  }



  ## end feat type loop






  ### dimension reduction ###
  dim_reduction_cell = gobject@dimension_reduction$cells

  for(i in 1:length(dim_reduction_names)) {

    temp_dim_red = dim_reductions[i]
    temp_dim_red_name = dim_reduction_names[i]

    if(verbose == TRUE) cat('write annotation data for: ', temp_dim_red, ' for ', temp_dim_red_name,'\n')

    write_giotto_viewer_dim_reduction(dim_reduction_cell = dim_reduction_cell,
                                      dim_red = temp_dim_red,
                                      dim_red_name = temp_dim_red_name,
                                      dim_red_rounding = dim_red_rounding,
                                      dim_red_rescale = dim_red_rescale,
                                      output_directory = output_directory)
  }




  ### expression data ###
  # expression values to be used
  if(verbose == TRUE) cat('\n write expression values \n')
  values = match.arg(expression_values, unique(c( 'scaled', 'normalized', 'custom', expression_values)))

  for(feat in feat_type) {
    expr_values = get_expression_values(gobject = gobject,
                                        feat_type = feat,
                                        values = values)
    expr_values = as.matrix(expr_values)

    # swap cell_IDs for numerical values
    colnames(expr_values) = 1:ncol(expr_values)
    # round values
    if(!is.null(expression_rounding)) {
      expr_values = round(x = expr_values, digits = expression_rounding)
    }
    data.table::fwrite(data.table::as.data.table(expr_values, keep.rownames="gene"), file=fs::path(output_directory, "giotto_expression.csv"), sep=",", quot=F, row.names=F, col.names=T)


    if(verbose == TRUE) cat('\n finished writing giotto viewer files to', output_directory , '\n')

    if(verbose == TRUE){
      cat("\n")
      cat("================================================================", "\n")
      cat("Next steps. Please manually run the following in a SHELL terminal:", "\n")
      cat("================================================================", "\n")
      cat("cd ", output_directory, "\n")
      cat("giotto_setup_image --require-stitch=n --image=n --image-multi-channel=n --segmentation=n --multi-fov=n --output-json=step1.json", "\n")
      cat("smfish_step1_setup -c step1.json", "\n")
      cat("giotto_setup_viewer --num-panel=2 --input-preprocess-json=step1.json --panel-1=PanelPhysicalSimple --panel-2=PanelTsne --output-json=step2.json --input-annotation-list=annotation_list.txt", "\n")
      cat("smfish_read_config -c step2.json -o test.dec6.js -p test.dec6.html -q test.dec6.css", "\n")
      cat("giotto_copy_js_css --output .", "\n")
      cat("python3 -m http.server", "\n")
      cat("================================================================", "\n")
      cat("\n")
      cat("Finally, open your browser, navigate to http://localhost:8000/. Then click on the file test.dec6.html to see the viewer.", "\n")
      cat("\n")
      cat("\n")
      cat("For more information, http://spatialgiotto.rc.fas.harvard.edu/giotto.viewer.setup3.html", "\n")
      cat("\n")
    }

  }

}





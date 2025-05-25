-- ensure codegen added to packages.yml file 
-- copy this file from codegen dbt package hub page
-- modify directory and prefix
-- highlight and compile code
-- copy compiled code as a template for docs .yml files for each respective directory

{% set models_to_generate = codegen.get_models(directory="core", prefix="") %}
{{ codegen.generate_model_yaml(model_names=models_to_generate) }}

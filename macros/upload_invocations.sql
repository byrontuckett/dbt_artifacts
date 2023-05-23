{% macro upload_invocations() -%}
    {{ return(adapter.dispatch('get_invocations_dml_sql', 'dbt_artifacts')()) }}
{%- endmacro %}

{% macro default__get_invocations_dml_sql() -%}
    {% set invocation_values %}
    select
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(1) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(2) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(3) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(4) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(5) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(6) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(7) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(8) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(9) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(10) }},
        nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(11) }}, ''),
        nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(12) }}, ''),
        nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(13) }}, ''),
        nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(14) }}, ''),
        nullif({{ adapter.dispatch('column_identifier', 'dbt_artifacts')(15) }}, ''),
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(16)) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(17)) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(18)) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(19)) }}
    from values
    (
        '{{ invocation_id }}', {# command_invocation_id #}
        '{{ dbt_version }}', {# dbt_version #}
        '{{ project_name }}', {# project_name #}
        '{{ run_started_at }}', {# run_started_at #}
        '{{ flags.WHICH }}', {# dbt_command #}
        '{{ flags.FULL_REFRESH }}', {# full_refresh_flag #}
        '{{ target.profile_name }}', {# target_profile_name #}
        '{{ target.name }}', {# target_name #}
        '{{ target.schema }}', {# target_schema #}
        {{ target.threads }}, {# target_threads #}

        '{{ env_var('DBT_CLOUD_PROJECT_ID', '') }}', {# dbt_cloud_project_id #}
        '{{ env_var('DBT_CLOUD_JOB_ID', '') }}', {# dbt_cloud_job_id #}
        '{{ env_var('DBT_CLOUD_RUN_ID', '') }}', {# dbt_cloud_run_id #}
        '{{ env_var('DBT_CLOUD_RUN_REASON_CATEGORY', '') }}', {# dbt_cloud_run_reason_category #}
        '{{ env_var('DBT_CLOUD_RUN_REASON', '') | replace("'","\\'") }}', {# dbt_cloud_run_reason #}

        {% if var('env_vars', none) %}
            {% set env_vars_dict = {} %}
            {% for env_variable in var('env_vars') %}
                {% do env_vars_dict.update({env_variable: (env_var(env_variable, '') | replace("'", "''"))}) %}
            {% endfor %}
            '{{ tojson(env_vars_dict) }}', {# env_vars #}
        {% else %}
            null, {# env_vars #}
        {% endif %}

        {% if var('dbt_vars', none) %}
            {% set dbt_vars_dict = {} %}
            {% for dbt_var in var('dbt_vars') %}
                {% do dbt_vars_dict.update({dbt_var: (var(dbt_var, '') | replace("'", "''"))}) %}
            {% endfor %}
            '{{ tojson(dbt_vars_dict) }}', {# dbt_vars #}
        {% else %}
            null, {# dbt_vars #}
        {% endif %}

        {# Only pull the required invocation args keys to avoid non-text keys #}
        {% set keys_to_find =  ["event_buffer_size", "indirect_selection", "no_print", "partial_parse", "printer_width", "profiles_dir", "quiet", "rpc_method", "select", "send_anonymous_usage_stats", "static_parser", "use_colors", "version_check", "which", "profile", "defer", "exclude", "full_refresh", "write_json", "resource_types", "state", "target", "cache_selected_only", "compile"] %}
        {% set new_invoke_args = {} %}
        {% for key in keys_to_find %}
            {% if key in invocation_args_dict | list  %}
                {% do new_invoke_args.update({key: invocation_args_dict[key]}) %}
            {% endif %}
        {% endfor %}
        '{{ tojson(new_invoke_args) | replace('\\', '\\\\') }}', {# invocation_args #}

        {% set metadata_env = {} %}
        {% for key, value in dbt_metadata_envs.items() %}
            {% do metadata_env.update({key: (value | replace("'", "''"))}) %}
        {% endfor %}
        '{{ tojson(metadata_env) | replace('\\', '\\\\') }}' {# dbt_custom_envs #}

    )
    {% endset %}
    {{ invocation_values }}

{% endmacro -%}

{% macro bigquery__get_invocations_dml_sql() -%}
    {% set invocation_values %}
        (
        '{{ invocation_id }}', {# command_invocation_id #}
        '{{ dbt_version }}', {# dbt_version #}
        '{{ project_name }}', {# project_name #}
        '{{ run_started_at }}', {# run_started_at #}
        '{{ flags.WHICH }}', {# dbt_command #}
        {{ flags.FULL_REFRESH }}, {# full_refresh_flag #}
        '{{ target.profile_name }}', {# target_profile_name #}
        '{{ target.name }}', {# target_name #}
        '{{ target.schema }}', {# target_schema #}
        {{ target.threads }}, {# target_threads #}

        '{{ env_var('DBT_CLOUD_PROJECT_ID', '') }}', {# dbt_cloud_project_id #}
        '{{ env_var('DBT_CLOUD_JOB_ID', '') }}', {# dbt_cloud_job_id #}
        '{{ env_var('DBT_CLOUD_RUN_ID', '') }}', {# dbt_cloud_run_id #}
        '{{ env_var('DBT_CLOUD_RUN_REASON_CATEGORY', '') }}', {# dbt_cloud_run_reason_category #}
        '{{ env_var('DBT_CLOUD_RUN_REASON', '') | replace("'","\\'") }}', {# dbt_cloud_run_reason #}

        {% if var('env_vars', none) %}
            {% set env_vars_dict = {} %}
            {% for env_variable in var('env_vars') %}
                {% do env_vars_dict.update({env_variable: (env_var(env_variable, ''))}) %}
            {% endfor %}
            parse_json('''{{ tojson(env_vars_dict) }}'''), {# env_vars #}
        {% else %}
            null, {# env_vars #}
        {% endif %}

        {% if var('dbt_vars', none) %}
            {% set dbt_vars_dict = {} %}
            {% for dbt_var in var('dbt_vars') %}
                {% do dbt_vars_dict.update({dbt_var: (var(dbt_var, ''))}) %}
            {% endfor %}
            parse_json('''{{ tojson(dbt_vars_dict) }}'''), {# dbt_vars #}
        {% else %}
            null, {# dbt_vars #}
        {% endif %}

        {% if invocation_args_dict.vars %}
            {# BigQuery does not handle the yaml-string from "--vars" well, when passed to "parse_json". Workaround is to parse the string, and then "tojson" will properly format the dict as a json-object. #}
            {% set parsed_inv_args_vars = fromyaml(invocation_args_dict.vars) %}
            {% do invocation_args_dict.update({'vars': parsed_inv_args_vars}) %}
        {% endif %}

        {# Only pull the required invocation args keys to avoid non-text keys #}
        {% set keys_to_find =  ["event_buffer_size", "indirect_selection", "no_print", "partial_parse", "printer_width", "profiles_dir", "quiet", "rpc_method", "select", "send_anonymous_usage_stats", "static_parser", "use_colors", "version_check", "which", "profile", "defer", "exclude", "full_refresh", "write_json", "resource_types", "state", "target", "cache_selected_only", "compile"] %}
        {% set new_invoke_args = {} %}
        {% for key in keys_to_find %}
            {% if key in invocation_args_dict | list  %}
                {% do new_invoke_args.update({key: fromyaml(invocation_args_dict[key])}) %}
            {% endif %}
        {% endfor %}
        {{ log(new_invoke_args, True) }}
        {# invocation_args_dict.vars, in the absence of any vars, results in the value "{}\n" as a string which results in an error. safe.parse_json accomodates for this gracefully. #}
        safe.parse_json('''{{ tojson(new_invoke_args) }}'''), {# invocation_args #}
        {% set metadata_env = {} %}
        {% for key, value in dbt_metadata_envs.items() %}
            {% do metadata_env.update({key: value}) %}
        {% endfor %}
        parse_json('''{{ tojson(metadata_env) | replace('\\', '\\\\') }}''') {# dbt_custom_envs #}

        )
    {% endset %}
    {{ invocation_values }}

{% endmacro -%}

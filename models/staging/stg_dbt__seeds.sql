with base as (

    select *
    from {{ ref('seeds') }}

),

enhanced as (

    select
        {{ dbt_artifacts.generate_surrogate_key(['command_invocation_id', 'node_id']) }} as seed_execution_id,
        command_invocation_id,
        node_id,
        run_started_at,
        {{ adapter.dispatch('quote_reserved_keywords', 'dbt_artifacts')('database') }},
        {{ adapter.dispatch('quote_reserved_keywords', 'dbt_artifacts')('schema') }},
        name,
        package_name,
        path,
        checksum,
        meta,
        alias
    from base

)

select * from enhanced

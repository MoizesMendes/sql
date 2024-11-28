SELECT 
    d.DealId, 
    d.dealname AS Name, 
    d.dealtype AS Type, 
    st.StageLabel AS Stage,
    pp.PipelineLabel AS Pipeline, 
    d.createdate AS CreateDate, 
    d.hs_lastmodifieddate AS LastModifiedDate,
    d.closedate,
    CONCAT(wn.FirstName, ' ', wn.LastName) AS Owner, 
    d.hubspot_owner_assigneddate AS OwnerAssignedDate,
    d.amount,
    d.hs_analytics_source AS DealSource,
    CASE 
        WHEN d.hs_analytics_source = 'OFFLINE' THEN 'Sales'
        WHEN d.hs_analytics_source IS NULL THEN 'Sales'
        ELSE 'Marketing'
    END AS SourceMarketingSales,
    d.hs_is_closed,
    d.hs_is_closed_won,
    d.hs_is_closed_lost,
    d.hs_likelihood_to_close,
    CASE
        WHEN d.hs_is_closed_lost = 'true' THEN 'Lost'
        WHEN d.hs_is_closed_won = 'true' THEN 'Won'
        ELSE 'Open'
    END AS CloseStatus,
    CASE    
        WHEN d.CreateDate > d.closedate THEN null
        WHEN d.hs_is_closed = 'true' THEN DATEDIFF(Day, d.CreateDate, d.closedate)
        ELSE DATEDIFF(Day, d.CreateDate, CURRENT_DATE)
    END AS LeadTime
FROM Deal AS d
LEFT JOIN DealPipelineStage AS st ON st.DealStage = d.dealstage
LEFT JOIN DealPipeline AS pp ON pp.PipelineId = d.pipeline
LEFT JOIN Owner AS wn ON wn.hubspot_owner_id = d.hubspot_owner_id
--- WHERE d.hs_analytics_source IS NULL
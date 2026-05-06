create or replace function get_smart_suppliers(
  user_lng float,
  user_lat float, 
  search_term text
)
returns table (
  name text,
  phone text,
  distance_km int,
  relevance_score int
)
language sql stable as $$
  select 
    s.name,
    s.phone,
    round(st_distance(s.location, st_point(user_lng, user_lat)::geography) / 1000)::int as distance_km,
    case when s.product_category ilike '%' || search_term || '%' then 100 else 0 end 
      - round(st_distance(s.location, st_point(user_lng, user_lat)::geography) / 1000)::int as relevance_score
  from suppliers s
  where st_dwithin(s.location, st_point(user_lng, user_lat)::geography, 200000)
  order by relevance_score desc
  limit 5;
$$;

DROP FUNCTION IF EXISTS get_smart_suppliers(float, float, text, float);

CREATE OR REPLACE FUNCTION get_smart_suppliers(
  user_lng FLOAT,
  user_lat FLOAT, 
  search_category TEXT,
  radius_km FLOAT DEFAULT 100
)
RETURNS TABLE (
  id BIGINT,                    -- BIGINT not INT
  name TEXT,
  country TEXT,
  region TEXT,
  lat FLOAT,
  lng FLOAT,
  phone TEXT,
  product_category TEXT,
  distance_km FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id, s.name, s.country, s.region, s.lat, s.lng, s.phone, s.product_category,
    6371 * acos(
      cos(radians(user_lat)) * cos(radians(s.lat)) * 
      cos(radians(s.lng) - radians(user_lng)) + 
      sin(radians(user_lat)) * sin(radians(s.lat))
    ) AS distance_km
  FROM suppliers s
  WHERE s.product_category = search_category
    AND 6371 * acos(
      cos(radians(user_lat)) * cos(radians(s.lat)) * 
      cos(radians(s.lng) - radians(user_lng)) + 
      sin(radians(user_lat)) * sin(radians(s.lat))
    ) <= radius_km
  ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION get_smart_suppliers(float, float, text, float) TO anon, authenticated;

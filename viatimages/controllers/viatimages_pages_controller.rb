class ViatimagesPagesController < PagesController
  def show
    slug = request[:slug]
    if request[:slug] == 'geosearch'
      # Include all images with coordinates
      pts = geo_images
      @pts_json = pts.to_json
    end

    super
  end


  def geo_images
    item_type = catalog.item_types.where(:slug => 'images').first!
    geo_attr = item_type.find_field('geo-location').uuid
    title_attr = item_type.find_field('titre-original').uuid
    img_attr = item_type.find_field('image').uuid


    items = ActiveRecord::Base.connection.execute("
      SELECT id, pt ->> 0 AS x, pt ->> 1 AS y, t, i FROM
      (
        SELECT
          I.id,
          ((I.data -> '#{geo_attr}' -> 'features' ->> 0 )::jsonb -> 'geometry' ->> 'coordinates')::jsonb as pt,
          I.data -> '#{title_attr}' AS t,
          I.data -> '#{img_attr}' ->> 'path' AS i
        FROM items I
        WHERE item_type_id = #{item_type.id}
        AND I.data -> '#{geo_attr}' IS NOT NULL
      ) A
    ")

    items
  end
end

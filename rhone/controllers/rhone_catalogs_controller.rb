class RhoneCatalogsController < CatalogsController
  def show
    # Update the Content Security Policy for displaying the map
    append_content_security_policy_directives(
      script_src: %w(http: data: blob:),
      img_src: %w(http: blob: 'unsafe-inline' 'unsafe-eval')
    )

    # Build a custom SQL query to extract efficiently all item values.
    # We need the id, coordinates, URL, a small thumb for the image, the title and date.
    # The URL can be built based on the item id, and the image URL based on the image upload path.

    carte_item_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'cartes').first

    title_field = carte_item_type.find_field('titre')
    date_field = carte_item_type.find_field('date')
    geom_field = carte_item_type.find_field('centroide')
    img_field = carte_item_type.find_field('carte')
    period_field = carte_item_type.find_field('periode-temporelle')

    @cartes = ActiveRecord::Base.connection.execute("
      SELECT 
        id,
        (data ->> '#{title_field.uuid}') AS title,
        (data ->> '#{date_field.uuid}') AS date,
        ((data ->> '#{geom_field.uuid}')::jsonb -> 'features' -> 0 -> 'geometry' -> 'coordinates' ->> 0)::double precision AS lng,
        ((data ->> '#{geom_field.uuid}')::jsonb -> 'features' -> 0 -> 'geometry' -> 'coordinates' ->> 1)::double precision AS lat,
        (data ->> '#{img_field.uuid}')::jsonb ->> 'path' AS img_path,
        (data ->> '#{period_field.uuid}')::jsonb AS periods
      FROM items
      WHERE item_type_id = #{carte_item_type.id}
      ORDER BY data ->> '#{title_field.uuid}'
    ")

    @cartes_json = @cartes.to_json
  end
end

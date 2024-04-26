class ViatimagesPagesController < PagesController
  def show
      if request[:slug] == 'geosearch'
      # A page with the "geosearch" slug should be available in the catalog. This page
      # should reference the "Image" item Type, and have a map container for each language.
      page = catalog.pages.find_by(slug: 'geosearch')

      return super unless page

      @container = page.containers.find_by(page_id: page.id, locale: I18n.locale.to_s)

      geofeature_classes_item_type = catalog.item_types.find_by(slug: 'geo-feature-classes')
      geofeature_item_type = catalog.item_types.find_by(slug: 'geo-features')

      # Find the items for multiple geographic classes
      @regions = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Region/Canton")
      @places = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Place name/Locality")
      @valleys = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Valley")
      @mountain_ranges = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Mountain range")
      @passes = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Pass")
      @mountains = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Mountain")
      @lakes = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Lake")
      @rivers = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Watercourse, river")
      @waterfalls = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Waterfall")
      @glaciers = find_geographic_items(geofeature_classes_item_type, geofeature_item_type, "Glacier")

      @geographic_images = request[:feature] ? geographic_images(request[:feature]) : nil
    end

    super
  end

  private

  def find_geographic_items(geofeature_classes_item_type, geofeature_item_type, class_name)
    geofeature_class_item = geofeature_classes_item_type.items.find_by(
      "(data->>'#{geofeature_classes_item_type.find_field('nom').uuid}')::jsonb->'_translations'->>'en' = ?", class_name
    )

    return [] unless geofeature_class_item

    geofeature_item_type.items.where(
      "data->>'#{geofeature_item_type.find_field('geo-feature-class').uuid}' = ?", geofeature_class_item.id.to_s
    ).order(Arel.sql("(data->>'#{geofeature_item_type.find_field('nom').uuid}')::jsonb->'_translations'->>'#{I18n.locale.to_s}'"))
  end

  def geographic_images(item_id)
    images_item_type = catalog.item_types.find_by(slug: 'images')
    images_geo_field = images_item_type.find_field('geo-location')
    images_geo_features_field = images_item_type.find_field('geo')

    return [] unless images_item_type && item_id && images_geo_field && images_geo_features_field

    geo_images_ids = find_geo_images(images_item_type, images_geo_features_field, item_id)
                   .pluck(:id)

    return [] unless geo_images_ids.present?

    features = { "type" => "FeatureCollection", "features" => [] }

    sql = build_sql_query(images_item_type, images_geo_field, geo_images_ids)

    res = ActiveRecord::Base.connection.execute(sql)

    data = JSON.parse(res[0]['geojson'])

    features['features'].concat(data['features']) if data['features'].present?

    features
  end

  def find_geo_images(images_item_type, images_geo_features_field, item_id)
    images_item_type.items.where(
      "(data->>'#{images_geo_features_field.uuid}')::jsonb @> ?", "[\"#{item_id}\"]"
    )
  end

  def build_sql_query(images_item_type, images_geo_field, geo_images_ids)
    <<-SQL.squish
      SELECT jsonb_build_object('features', CASE WHEN (array_agg(feat) IS NOT NULL) THEN array_to_json(array_agg(feat)) ELSE '[]' END) AS geojson
      FROM (
        SELECT jsonb_build_object('geometry', jsonb_array_elements(feats)->'geometry', 'properties', jsonb_build_object('id', id, 'polygon_color', '#{images_geo_field.polygon_color}', 'polyline_color', '#{images_geo_field.polyline_color}'), 'type', 'Feature') AS feat
        FROM (
          SELECT id, data->'#{images_geo_field.uuid}'->'features' AS feats
          FROM items
          WHERE item_type_id = #{images_item_type.id} AND data->'#{images_geo_field.uuid}'->'features' IS NOT NULL
          AND id IN (#{geo_images_ids.join(',')})
        ) A
      ) B
    SQL
  end
end

class ViatimagesCatalogsController < CatalogsController
  def show
    image_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'images')

    # Retrieve & sort the all the corpus
    corpus_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'corpus')
    @corpus_type_items = nil if corpus_type.empty?
    corpus_title_field = corpus_type.first.find_field('title')
    @corpus_type_items = Item.where(item_type_id: corpus_type.ids.first).sorted_by_field(corpus_title_field)

    # Retrieve & sort the all the domains
    domain_choice_set = ChoiceSet.where(catalog_id: @catalog.id).where(name: 'Domaines')
    domain_choice_set_items = domain_choice_set.empty? ? nil : Choice.where(choice_set_id: domain_choice_set.ids.first).sorted
    @domain_choice_set_items = {}
    domain_choice_set_items.each do |domain|
      value_slug = [I18n.locale, domain.short_name].join("-")
      link = [I18n.locale, "images?domaine=#{value_slug}"].join("/")
      @domain_choice_set_items.store(domain, link)
    end

    # Retrieve the first 20 most used keywords
    # Make a single raw SQL query to avoid 20+ queries
    image_type_keyword_field = image_type.present? ? image_type.first.find_field('mot-cle') : nil
    keywords_attribute = image_type_keyword_field.uuid
    keyword_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'keywords')
    keyword_name_field = keyword_type.first.find_field('mot').uuid

    keywords = ActiveRecord::Base.connection.execute("
      SELECT (I.data ->> '#{keyword_name_field}')::jsonb->'_translations'->>'#{I18n.locale}' AS keyword, n
      FROM items I
      JOIN (
        WITH keyword_ids AS (
          SELECT jsonb_array_elements_text((data ->> '#{keywords_attribute}')::jsonb)::int AS kid
          FROM items
          WHERE data -> '#{keywords_attribute}' IS NOT NULL
        )
        SELECT kid, COUNT(*) AS n
        FROM keyword_ids
        GROUP BY kid
        LIMIT 20
      ) A ON I.id = A.kid
      ORDER BY n DESC")

    @keywords = []
    keyword_size_classes = ['largest', 'large', 'medium', 'small']
    keywords.each_with_index do |kw, idx|
      @keywords.push([kw['keyword'], keyword_size_classes[idx / 5]])
    end
    @keywords.sort_by! { |v| v[0] }
    @keywords_base_url = [I18n.locale, "search?utf8=✓&type=images&q="].join("/")
  end
end

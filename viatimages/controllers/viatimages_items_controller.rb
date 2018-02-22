class ViatimagesItemsController < ItemsController
  include FieldsHelper

  def index
    super

    # If corpus id request parameter is available, send corresponding corpus item to view
    @corpus = Item.where(id: params['corpus']).first if params['corpus'].present?
  end
  def show
    super

    @corpus_item_type_slug = "corpus"
    @image_item_type_image_slug = "images"

    # Prepare some objects for the view according to the item type slug
    case @item_type.slug
      when @corpus_item_type_slug
        # objects for the "corpus" item type
        @item.applicable_fields.each do |field|
          @lieu_edition = field if field.slug == "lieu-edition"
          @tome_volume = field if field.slug == "tome-volume"
          @langue_ouvrage = field if field.slug == "langue-ouvrage"
          @collection_ouvrage = field if field.slug == "collection-ouvrage"
          @autre_editions = field if field.slug == "autres-editions"
        end
        @etablissement = @item.get_value('etablissement')
        fields_and_item_references(@item) do |field, browse| @images_count = browse.total_count end
      when @image_item_type_image_slug
        # objects for the "images" item type
    end
  end
end
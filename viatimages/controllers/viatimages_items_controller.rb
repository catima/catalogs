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
          @titre = field if field.slug == "titre"
          #@titre_trad = field if field.slug == "titre-traduit"
          @titre_long = field if field.slug == "titre-long"
          @lieu_edition = field if field.slug == "lieu-edition"
          @editeur = field if field.slug == "editeur"
          #@personne_associee = field if field.slug == "personne-associee"
          @siecle_edition = field if field.slug == "siecle-edition"
          @siecle_voyage = field if field.slug == "siecle-voyage"
          @date_edition_debut = field if field.slug == "date-edition-debut"
          @date_edition_fin = field if field.slug == "date-edition-fin"
          @format = field if field.slug == "format"
          @tome = field if field.slug == "tome"
          @nombre_illustrations = field if field.slug == "nombre-illustrations"
          @cote = field if field.slug == "cote"
          @url_catalogue = field if field.slug == "url-catalogue"
          @remarques = field if field.slug == "remarques"
          #@textes_online = field if field.slug == "textes-online"
          @collection_ouvrage = field if field.slug == "collection-ouvrage"
          @langue_ouvrage = field if field.slug == "langue-ouvrage"
          @autres_editions = field if field.slug == "autres-editions"
          @provenance_collection = field if field.slug == "provenance"
          @description_collection = field if field.slug == "description"
        end

        @etablissement = @item.get_value('etablissement')
        fields_and_item_references(@item) do |_, browse| @images_count = browse.total_count end

      when @image_item_type_image_slug
        # objects for the "images" item type
        @item.applicable_fields.each do |field|
          @image_id = field if field.slug == "image-id"
          @image = field if field.slug == "image"
          @texte_dans_image = field if field.slug == "texte-dans-image"
          @titre_original = field if field.slug == "titre-original"
          #@titre = field if field.slug == "title"
          #@illustrateurs = field if field.slug == "personne-associee"
          @corpus = field if field.slug == "corpus"
          @description = field if field.slug == "description"
          @remarques = field if field.slug == "remarques"
          @image_lieu_edition = field if field.slug == "image-lieu-edition"
          @date_evenement = field if field.slug == "date-evenement"
          @illustration_composee = field if field.slug == "illustration-composee"
          @planche_depliante = field if field.slug == "planche-depliante"
          @en_couleur = field if field.slug == "en-couleurs"
          @largeur = field if field.slug == "largeur"
          @hauteur = field if field.slug == "hauteur"
          @echelle_origine = field if field.slug == "echelle-origine"
          @emplacement = field if field.slug == "emplacement"
          @emplacement_ouvrage = field if field.slug == "emplacement-dans-ouvrage"
          @genre = field if field.slug == "genre"
          @descripteur_carte = field if field.slug == "descripteur-carte"
          @critere_technique = field if field.slug == "critere-technique"
          @location = field if field.slug == "geo-location"
          @domaine = field if field.slug == "domaine"
          @keyword = field if field.slug == "mot-cle"
          @geographie = field if field.slug == "geo"
          @texte_legende = field if field.slug == "texte-legende"
          @chercheur = field if field.slug == "chercheur"
          @texte_associe = field if field.slug == "texte-associe"
        end

        # define image thumbnail size
        @image_size = '400x400'

        # get local value for boolean true
        @yes = t('yes')

        if @geographie
          # regroup all geography values by feature-class
          @geographie_sorted = @item.get_value(@geographie).group_by{|item| item.item_type.find_field('geo-feature-class').raw_value(item)}.values
        end
    end
  end
end

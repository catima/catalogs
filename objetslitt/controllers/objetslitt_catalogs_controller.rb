class ObjetslittCatalogsController < CatalogsController
    def show
        # Get the ItemType for the 'objets' type
        objet_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'objets')
        # Get all the items of type 'objets'
        objets = Item.where(item_type_id: objet_type.ids.first)

        # Get a random object from all the objets
        random_object = objets.sample

        # Access the "nom" attribute from the random object
        @daily_object_name = random_object.data["_ea331def_2f53_4840_a2ac_136cefe48ce5"]
        # Generate the URL to go see the object page
        @daily_object_url = "/objetslitt/fr/objets/#{random_object.id}"
    end
end

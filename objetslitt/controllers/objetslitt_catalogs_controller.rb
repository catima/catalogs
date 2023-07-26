class ObjetslittCatalogsController < CatalogsController
    def show
        # Check if the object of the day's ID is already cached for today
        object_id = Rails.cache.fetch("objetslitt_daily_objet_id", expires_in: 1.day) do
            # If the cache is not set or expired, get a new object and store its ID in the cache
            set_daily_objet_id
        end
    
        # Retrieve the object using the cached ID
        daily_object = Item.find_by(id: object_id)

        if daily_object == nil
            return
        end
        # Display the daily object
        # Access the "nom" attribute from the random object
        @daily_object_name = daily_object.data["_ea331def_2f53_4840_a2ac_136cefe48ce5"]
        # Generate the URL to go see the object page
        @daily_object_url = "/objetslitt/fr/objets/#{daily_object.id}"
    end

    private

    def set_daily_objet_id
        # Get the ItemType for the 'objets' type
        objet_type = ItemType.where(catalog_id: @catalog.id).where(slug: 'objets')
        # Get all the items of type 'objets'
        objets = Item.where(item_type_id: objet_type.ids.first)

        # Get a random object from all the objects
        random_objet = objets.sample

        random_objet.id
    end
end

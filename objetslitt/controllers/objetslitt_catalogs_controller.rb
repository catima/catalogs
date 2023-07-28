class ObjetslittCatalogsController < CatalogsController
    def show
        # Check if the object of the day's ID is already cached for today
        object_id = Rails.cache.fetch("objetslitt_daily_objet_id", expires_in: end_of_day) do
            # If the cache is not set or expired, get a new object and store its ID in the cache
            set_daily_objet_id
        end
    
        # Retrieve the object using the cached ID
        daily_object = Item.find_by(id: object_id)

        if daily_object == nil
            return
        end

        # Display the daily object
        # First, get the UUIDs of the fields in the objet item type.
        objet_type = ItemType.where(catalog_id: @catalog.id).where(slug: "objets")

        nom = objet_type.first.find_field("nom").uuid
        # Field "Description des fonctions textuelles"
        descripfct = objet_type.first.find_field("descripfct").uuid

        # Access the data attribute from the random objet, using the UUIDs
        @daily_object_name = daily_object.data[nom]
        # Access the "content" attribute of the JSON, which is an HTML snippet
        # (rendered in `views/catalogs/show.html.erb`)
        @daily_object_description = JSON.parse(daily_object.data[descripfct])["content"]

        # Generate the URL to go see the object page
        @daily_object_url = "/objetslitt/#{I18n.locale}/objets/#{daily_object.id}"
    end

    private

    def set_daily_objet_id
        # Get the ItemType for the "objets" type
        objet_type = ItemType.where(catalog_id: @catalog.id).where(slug: "objets")
        # Get all the items of type "objets"
        objets = Item.where(item_type_id: objet_type.ids.first)

        # Get a random object from all the objects
        random_objet = objets.sample

        random_objet.id
    end

    def end_of_day
        # Make sure that the cached id expires every day at midnight.
        # Calculate the time remaining until the end of the day (23:59:59)
        seconds_until_end_of_day = Time.zone.now.end_of_day - Time.zone.now
    
        # Ensure the expiration time is within 24 hours to avoid cache buildup
        [seconds_until_end_of_day, 24.hours].min
    end
end

class ObjetslittCatalogsController < CatalogsController
    def show
        # Check if the object of the day's ID is already cached for today
        item_id = Rails.cache.fetch("objetslitt_daily_item_id", expires_in: time_until_end_of_day) do
            # If the cache is not set or expired, get a new object and store its ID in the cache
            set_daily_item_id
        end
    
        # Retrieve the object using the cached ID
        @daily_item = Item.find_by(id: item_id)

        if @daily_item == nil
            return
        end

        # Display the daily object
        # First, get the UUIDs of the fields in the objet item type.
        objet_type = ItemType.where(catalog_id: @catalog.id).where(slug: "objets")

        nom = objet_type.first.find_field("nom").uuid
        # Field "Description des fonctions textuelles"
        descripfct = objet_type.first.find_field("descripfct").uuid
        cover = objet_type.first.find_field("cover").uuid

        # Access the data attribute from the random objet, using the UUIDs
        @daily_item_name = @daily_item.data[nom]
        # Access the "content" attribute of the JSON, which is an HTML snippet
        # (rendered in `views/catalogs/show.html.erb`)
        @daily_item_description = JSON.parse(@daily_item.data[descripfct])["content"]
        @daily_item_cover = @daily_item.data[cover]

        if @daily_item_cover != nil
            @daily_item_cover = "/" + @daily_item_cover["path"]
        end

        # Generate the URL to go see the object page
        @daily_item_url = "/objetslitt/#{I18n.locale}/objets/#{@daily_item.id}"
    end

    private

    def set_daily_item_id
        # Get the ItemType for the "objets" type
        objet_type = ItemType.where(catalog_id: @catalog.id).where(slug: "objets")
        # Get all the items of type "objets"
        items = Item.where(item_type_id: objet_type.ids.first)

        # Get a random object from all the objects
        random_item = items.sample

        random_item.id
    end

    def time_until_end_of_day
        # Makes sure that the cached item ID expires every day at midnight.
        # Calculate the time remaining until the end of the day (23:59:59)
        Time.zone.now.end_of_day - Time.zone.now
    end
end

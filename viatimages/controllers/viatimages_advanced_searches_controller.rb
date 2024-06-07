class ViatimagesAdvancedSearchesController < AdvancedSearchesController
  def new
    super

    # Sort the advance search configurations by slug to always have the
    # "image" configuration as the first one.
    @advance_search_confs = @advance_search_confs.to_a.sort_by { |conf|
      conf.slug
    }.reverse
  end
  def show
    super
  end
end

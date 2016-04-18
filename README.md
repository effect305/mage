# Mage

Mage can be used for making model creation wizards with step by step validations in Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mage'
```

And then execute:

    $ bundle install

After that generate migration:

    $ rails g mage

And migrate your database:

    $ rake db:migrate

## Usage

Define steps in your model:

```ruby
class Product < ActiveRecord::Base
  has_mage_steps :name, :price, :category
end
```

Add validations for each step, using mage_step_STEPNAME? syntax:

```ruby
  validates :name, presence: true, if: :mage_step_name?
  validates :price, presence: true, if: :mage_step_price?
  validates :category, presence: true, if: :mage_step_category?
```

You can use also custom validators or anything you want, just define on which step they should be run.
Also bear in mind that each step runs validations of all previous steps. Step increases after
successful save of the object.

After that create steps subdirectory in views directory of your controller.

    $ mkdir app/views/products/steps

Put there templates for each step, naming them like steps. You can use form_for helper in your templates:

```ruby
<h1>Creating new product, step 1</h1>
<%= form_for @product do |f| %>
    <%= f.label :name %>
    <%= f.text_field :name %>
    <%= f.submit %>
<% end %>
```

And the main part, it's time to set up your controller! Use render_mage method with your object as argument
in each place that you want to render wizard. This method will render necessary template from steps directory
according to the state of the object.

```ruby
  def new
    @product = Product.new
    render_mage(@product)
  end

  def create
    @product = Product.new(product_params)
    @product.save
    render_mage(@product)
  end

  def edit
    @product = Product.find(params[:id])
    render_mage(@product)
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    render_mage(@product)
    redirect_to product_path(@product)
  end
```

Take a look at update action in our example, there's redirect_to method after render_mage. Yes, this code
will be executed only if your object is finished wizard, if not - wizard will be rendered, and all the code
below render_mage won't be executed, so you don't need to worry about that.

Also if tou want to show current step in url as a param, you can use show_step option each time you call
render_mage method like this:

```ruby
render_mage(@product, show_step: true)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/effect305/mage.

## ToDo

I think there's a lot of stuff to do. Here's just examples:
* ~~Keep flash messages if showing step~~
* ~~Generator~~
* Back button
* Tests

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


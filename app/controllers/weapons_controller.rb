class WeaponsController < ApplicationController
    before_action :set_weapon, only: [:edit, :update, :destroy]

  def index
    @weapons = Weapon.order(:weapon_type, :name)
    @weapon = Weapon.new
  end

  def create
    @weapon = Weapon.new(weapon_params)

    if @weapon.save
      redirect_to weapons_path, notice: 'Weapon added successfully.'
    else
      @weapons = Weapon.order(:weapon_type, :name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @weapon.update(weapon_params)
      redirect_to weapons_path, notice: 'Weapon updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @weapon.destroy
    redirect_to weapons_path, notice: 'Weapon removed successfully.'
  end

  private

  def set_weapon
    @weapon = Weapon.find(params[:id])
  end

  def weapon_params
    params.require(:weapon).permit(:name, :weapon_type)
  end
end

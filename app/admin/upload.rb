ActiveAdmin.register Upload do
  menu priority: 999
  actions :index, :new, :create, :show
  before_action :set_user, only: [:create]

  permit_params :model, :file, :user_id

  index do
    id_column
    column :pt_model
    column :user
    column :created_at
    actions
  end

  form title: 'Upload Tabela' do |f|
    f.inputs "" do
      f.input :model, collection: Upload.model.values.map { |m| [I18n.t("activerecord.models.#{m}.other"), m]}
      f.input :file, as: :file
    end
    f.actions
  end

  controller do

    def create(options={}, &block)
      create! do |format|
        format.html do
          if resource.errors.any?
            flash.now[:error] = resource.errors.to_a.join("<br/>").html_safe
            render 'active_admin/resource/new.html.arb' and return
          else
            redirect_to uploads_path, flash: { notice: "Arquivo importado com sucesso!" }
          end
        end
      end
    end

    def build_new_resource
      upload = super
      if action_name == 'new' && params[:model]
        upload.model = params[:model]
      end
      upload
    end

    def set_user
      params[:upload][:user_id] = current_user.id
    end
  end
end

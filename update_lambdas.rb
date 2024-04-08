require 'aws-sdk-lambda'
require 'zip'

lambda_client = Aws::Lambda::Client.new(region: 'ca-central-1')

function_names = %w[some_party_subscribe some_party_unsubscribe some_party_resend some_party_enter_contest]

function_names.each do |function_name|
  zip_file_path = "./tmp/#{function_name}.zip"
  FileUtils.rm_f(zip_file_path)
  Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
    zipfile.add('lambda_function.rb', "./lambda/#{function_name}/lambda_function.rb")
  end

  # Upload to Lambda
  lambda_client.update_function_code(
    function_name:,
    zip_file: File.binread(zip_file_path)
  )

  puts "Lambda function #{function_name} deployed successfully!"
end

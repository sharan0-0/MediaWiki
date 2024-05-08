provider "aws" {
  version                 = "~> 0.13.4"
  region                  = "us-east-1"
  #shared_credentials_file = "/Users/home/.aws/credentials" ## {user-name} : Replace it with your username and path with your to allow access to aws credentials files
  profile                 = "{profile}"                           ## {profile} : Enter the profile that you want to use. By Default the profile is : default
}

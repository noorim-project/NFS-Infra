resource "aws_s3_bucket" "static_bucket" {
  bucket = "noorim.istruly.sexy"
  acl = "public-read"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::noorim.istruly.sexy/*"]
    }
  ]
}
EOF
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}


resource "aws_acm_certificate" "certificate" {
  provider = "aws.us-east-1"
  domain_name = "*.istruly.sexy"
  validation_method = "EMAIL"

  subject_alternative_names = ["istruly.sexy"]
}


resource "aws_cloudfront_distribution" "noorim_cloud_front" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${aws_s3_bucket.static_bucket.website_endpoint}"
    origin_id   = "noorim.istruly.sexy"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "noorim.istruly.sexy"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["noorim.istruly.sexy"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
  }
}


resource "aws_route53_zone" "istruly_sexy" {
  name = "istruly.sexy"
}


resource "aws_route53_record" "noorim_istruly_sexy" {
  name = "noorim.istruly.sexy"
  type = "A"
  zone_id = "${aws_route53_zone.istruly_sexy.zone_id}"

  alias {
    evaluate_target_health = false
    name = "${aws_cloudfront_distribution.noorim_cloud_front.domain_name}"
    zone_id = "${aws_cloudfront_distribution.noorim_cloud_front.hosted_zone_id}"
  }
}

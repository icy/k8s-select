#!/usr/bin/env ruby

# Purpose : Select the objects you want from maninfests,
#           as you may not want to deploy everything.
# Author  : Ky-Anh Huynh
# Date    : 2019-12
# License : MIT
# Example :
#
#    helm template . | k8s-select kind=Ingress | kubectl diff -f-
#    helm template . | k8s-select metadata.name=someth | kubectl diff -f-
#    kustomization build . | k8s-select kind='(Deployment|Daemonset)'
#
#    helm template . | k8s-select "kind!=Ingress" | kubectl diff -f-
#
# NOTE 1  : For exact match, please use regular expression, for example: `k8s-select.rb kind=^Role$`
# NOTE 2  : When multiple filters are used, OR operator is used to match input data against any of the filters.
# NOTE 2x : For that reason, using multiple negative matching (`!=`) may not take any effect.
#
require 'yaml'

class NilClass
  def dig(st)
    return nil
  end
end

def doc_query(doc,query)
  key = ""
  val = doc
  query.split(".").each do |k|
    if gs = k.to_s.match(%r{\[([0-9]+)\]})
      val = val.is_a?(Array) ? val[gs[1].to_i] : nil
    else
      val = val.dig(k)
    end
  end
  return val ? val.downcase : nil
end

def match_argv_doc(args,doc)
  ret_neg = args.select{|s| s.include?("!=")}.detect do |arg|
    query,value = arg.split("!=", 2)
    query_value = doc_query(doc, query)
    query_value.nil? ? true : (not query_value.match(value.downcase))
  end

  return ret_neg if ret_neg

  args.select{|s| s.include?("=")}.detect do |arg|
    query,value = arg.split("=", 2)
    query_value = doc_query(doc, query)
    query_value.nil? ? nil: query_value.match(value.downcase)
  end
end

docs = YAML.load_stream(STDIN)
docs.each do |doc|
  next if doc.nil? or doc.empty?
  if match_argv_doc(ARGV,doc)
    puts YAML.dump(doc)
  end
end

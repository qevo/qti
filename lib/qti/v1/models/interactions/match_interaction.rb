module Qti
  module V1
    module Models
      module Interactions
        class MatchInteraction < BaseInteraction
          def self.matches(node)
            matches = node.xpath('.//xmlns:response_lid')
            return false if matches.count <= 1
            new(node)
          end

          def answers
            @answers ||= answer_nodes.map do |node|
              V1::Models::Choices::LogicalIdentifierChoice.new(node)
            end
          end

          def questions
            node.xpath('.//xmlns:response_lid').map do |lid_node|
              item_body = lid_node.at_xpath('.//xmlns:mattext').text
              { id: lid_node.attributes['ident'].value, itemBody: item_body }
            end
          end

          def scoring_data_structs
            matches = node.xpath('.//xmlns:varequal').map do |node|
              [node.attributes['respident'].value, answers_map[node.content]]
            end
            [Models::ScoringData.new(Hash[matches], rcardinality)]
          end

          private

          def answers_map
            @answers_map ||= answers.reduce({}) do |acc, answer|
              acc.update answer.identifier => answer.item_body
            end
          end

          def answer_nodes
            responses = []
            response_ids = {}
            node.xpath('.//xmlns:response_label').each do |answer_node|
              ident = answer_node.attributes['ident'].value
              responses << answer_node unless response_ids.key? ident
              response_ids[ident] = 1
            end
            responses
          end
        end
      end
    end
  end
end

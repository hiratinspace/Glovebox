import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { DisplayMessage } from './types';
import { citationLabel } from '../retrieval/citation';

export function MessageBubble({ message }: { message: DisplayMessage }) {
  const isUser = message.role === 'user';
  return (
    <View style={[styles.row, isUser ? styles.rowUser : styles.rowAssistant]}>
      <View style={[styles.bubble, isUser ? styles.bubbleUser : styles.bubbleAssistant]}>
        <Text style={isUser ? styles.textUser : styles.textAssistant}>
          {message.text}
          {message.isStreaming ? ' ▌' : ''}
        </Text>
      </View>
      {!isUser && message.citations && message.citations.length > 0 && (
        <View style={styles.citationRow}>
          {message.citations.map(c => (
            <View key={c.item.id} style={styles.citationTag}>
              <Text style={styles.citationText}>Source: {citationLabel(c.item)}</Text>
            </View>
          ))}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    marginVertical: 6,
    maxWidth: '85%',
  },
  rowUser: {
    alignSelf: 'flex-end',
  },
  rowAssistant: {
    alignSelf: 'flex-start',
  },
  bubble: {
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  bubbleUser: {
    backgroundColor: '#2f6fed',
  },
  bubbleAssistant: {
    backgroundColor: '#e7e9ee',
  },
  textUser: {
    color: '#ffffff',
    fontSize: 15,
  },
  textAssistant: {
    color: '#1a1a1a',
    fontSize: 15,
  },
  citationRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 6,
    gap: 6,
  },
  citationTag: {
    backgroundColor: '#fff4d6',
    borderRadius: 8,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderWidth: 1,
    borderColor: '#e0c97a',
  },
  citationText: {
    fontSize: 11,
    color: '#7a5b00',
    fontWeight: '600',
  },
});

import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { LlamaContext } from 'llama.rn';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { DisplayMessage } from './types';
import { OfflineIndicator } from './OfflineIndicator';
import { MessageBubble } from './MessageBubble';
import { useOnlineStatus } from './useOnlineStatus';
import { getCachedContent } from '../content/cachedContentProvider';
import { retrieve } from '../retrieval/retrieve';
import { buildPrompt } from '../retrieval/buildPrompt';
import { loadLlamaContext, runInference } from '../llm/llamaService';

let nextId = 0;
function makeId(): string {
  nextId += 1;
  return `msg-${nextId}`;
}

type ModelStatus = 'loading' | 'ready' | 'error';

export function ChatScreen() {
  const insets = useSafeAreaInsets();
  const isOnline = useOnlineStatus();

  const [modelStatus, setModelStatus] = useState<ModelStatus>('loading');
  const [loadProgress, setLoadProgress] = useState(0);
  const [loadError, setLoadError] = useState<string | null>(null);
  const contextRef = useRef<LlamaContext | null>(null);

  const [messages, setMessages] = useState<DisplayMessage[]>([]);
  const [input, setInput] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);

  useEffect(() => {
    loadLlamaContext(progress => setLoadProgress(progress))
      .then(ctx => {
        contextRef.current = ctx;
        setModelStatus('ready');
      })
      .catch(err => {
        setLoadError(err instanceof Error ? err.message : String(err));
        setModelStatus('error');
      });
  }, []);

  const handleSend = useCallback(async () => {
    const query = input.trim();
    const context = contextRef.current;
    if (!query || !context || isGenerating) return;

    setInput('');
    const userMessage: DisplayMessage = { id: makeId(), role: 'user', text: query };
    const assistantId = makeId();
    const assistantMessage: DisplayMessage = {
      id: assistantId,
      role: 'assistant',
      text: '',
      isStreaming: true,
    };
    setMessages(prev => [...prev, userMessage, assistantMessage]);
    setIsGenerating(true);

    try {
      // Standalone for now: pulls every chunk/waypoint via getCachedContent().
      // Travel Mode swaps the provider behind that call to a vehicleId +
      // route-scoped subset — no change needed here.
      const cachedContent = getCachedContent();
      const retrieved = retrieve(query, cachedContent, 3);
      const prompt = buildPrompt(query, retrieved);

      let accumulated = '';
      await runInference(context, prompt, token => {
        accumulated += token;
        setMessages(prev =>
          prev.map(m => (m.id === assistantId ? { ...m, text: accumulated } : m)),
        );
      });

      setMessages(prev =>
        prev.map(m =>
          m.id === assistantId
            ? { ...m, text: accumulated, isStreaming: false, citations: retrieved }
            : m,
        ),
      );
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      setMessages(prev =>
        prev.map(m =>
          m.id === assistantId
            ? { ...m, text: `Something went wrong: ${message}`, isStreaming: false }
            : m,
        ),
      );
    } finally {
      setIsGenerating(false);
    }
  }, [input, isGenerating]);

  return (
    <KeyboardAvoidingView
      style={[styles.container, { paddingTop: insets.top }]}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={styles.header}>
        <Text style={styles.title}>Glovebox</Text>
        <OfflineIndicator isOnline={isOnline} />
      </View>

      {modelStatus === 'loading' && (
        <View style={styles.centerFill}>
          <ActivityIndicator size="large" />
          <Text style={styles.statusText}>
            Loading on-device model… {Math.round(loadProgress * 100)}%
          </Text>
        </View>
      )}

      {modelStatus === 'error' && (
        <View style={styles.centerFill}>
          <Text style={styles.errorText}>Failed to load the model.</Text>
          <Text style={styles.statusText}>{loadError}</Text>
        </View>
      )}

      {modelStatus === 'ready' && (
        <>
          <FlatList
            data={messages}
            keyExtractor={m => m.id}
            renderItem={({ item }) => <MessageBubble message={item} />}
            contentContainerStyle={styles.messageList}
          />
          <View style={[styles.inputRow, { paddingBottom: insets.bottom || 12 }]}>
            <TextInput
              style={styles.input}
              value={input}
              onChangeText={setInput}
              placeholder="Ask about your vehicle…"
              editable={!isGenerating}
              onSubmitEditing={handleSend}
              returnKeyType="send"
            />
            <TouchableOpacity
              style={[styles.sendButton, isGenerating && styles.sendButtonDisabled]}
              onPress={handleSend}
              disabled={isGenerating || !input.trim()}
            >
              <Text style={styles.sendButtonText}>Send</Text>
            </TouchableOpacity>
          </View>
        </>
      )}
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  header: {
    paddingHorizontal: 16,
    paddingBottom: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
  },
  centerFill: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  statusText: {
    marginTop: 10,
    fontSize: 13,
    color: '#555',
    textAlign: 'center',
  },
  errorText: {
    fontSize: 15,
    fontWeight: '600',
    color: '#c33',
    marginBottom: 6,
  },
  messageList: {
    paddingHorizontal: 16,
    paddingBottom: 8,
    flexGrow: 1,
  },
  inputRow: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#eee',
    alignItems: 'flex-end',
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 18,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 15,
    maxHeight: 100,
  },
  sendButton: {
    marginLeft: 8,
    backgroundColor: '#2f6fed',
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  sendButtonDisabled: {
    backgroundColor: '#a9bdf0',
  },
  sendButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
});
